<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import VueApexCharts from 'vue3-apexcharts'
import { CurrencyDollarIcon, ShoppingBagIcon, ArrowTrendingUpIcon } from '@heroicons/vue/24/outline'
import apiClient from '@/api/axios'

const filterPeriod = ref('month')
const isLoading = ref(false)
const currentTab = ref('revenue')
const packageSalesData = ref([])

const formatPrice = (value) => new Intl.NumberFormat('vi-VN').format(value || 0) + ' đ'

const totalRevenue = ref(0)
const orderCount = ref(0)
const averageOrderValue = ref(0)

const summary = computed(() => [
  { id: 1, name: 'Tổng doanh thu',    value: formatPrice(totalRevenue.value),       icon: CurrencyDollarIcon,  color: 'text-success', bg: 'bg-success bg-opacity-10' },
  { id: 2, name: 'Đơn hàng hoàn tất', value: orderCount.value.toString(),            icon: ShoppingBagIcon,     color: 'text-primary', bg: 'bg-primary bg-opacity-10' },
  { id: 3, name: 'Trung bình/đơn',    value: formatPrice(averageOrderValue.value),   icon: ArrowTrendingUpIcon, color: 'text-warning', bg: 'bg-warning bg-opacity-10' },
])

const revenueSeries = ref([{ name: 'Doanh thu', data: [] }])
const revenueOptions = ref({
  chart: { type: 'area', height: 350, toolbar: { show: false }, fontFamily: 'Be Vietnam Pro, sans-serif' },
  colors: ['#2E7D32'],
  fill: { type: 'gradient', gradient: { shadeIntensity: 1, opacityFrom: 0.35, opacityTo: 0.05, stops: [0, 100] } },
  dataLabels: { enabled: false },
  stroke: { curve: 'smooth', width: 2.5 },
  xaxis: { categories: [], axisBorder: { show: false }, axisTicks: { show: false }, labels: { style: { fontSize: '11px', colors: '#9ca3af' } } },
  yaxis: { labels: { formatter: (v) => formatPrice(v), style: { fontSize: '11px', colors: '#9ca3af' } } },
  grid: { borderColor: '#f3f4f6', strokeDashArray: 4 },
  tooltip: { y: { formatter: (v) => formatPrice(v) } }
})

const topProductsSeries = ref([{ name: 'Đã bán', data: [] }])
const topProductsOptions = ref({
  chart: { type: 'bar', height: 350, toolbar: { show: false }, fontFamily: 'Be Vietnam Pro, sans-serif' },
  colors: ['#0ea5e9'],
  plotOptions: { bar: { borderRadius: 0, horizontal: true, barHeight: '55%' } },
  dataLabels: { enabled: false },
  xaxis: { categories: [], labels: { style: { fontSize: '11px', colors: '#9ca3af' } } },
  yaxis: { labels: { style: { fontSize: '12px', colors: '#374151' } } },
  grid: { borderColor: '#f3f4f6', strokeDashArray: 4 },
  tooltip: { y: { formatter: (v) => v + ' sản phẩm' } }
})

const getDateFilter = () => {
  const now = new Date()
  let fromDate = null
  let toDate = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59)
  let groupBy = 'day'

  if (filterPeriod.value === 'today') {
    fromDate = new Date(now.getFullYear(), now.getMonth(), now.getDate())
    groupBy = 'day'
  } else if (filterPeriod.value === 'week') {
    const day = now.getDay()
    const diff = now.getDate() - day + (day === 0 ? -6 : 1)
    fromDate = new Date(now.getFullYear(), now.getMonth(), diff)
    fromDate.setHours(0, 0, 0, 0)
    toDate = new Date(fromDate.getFullYear(), fromDate.getMonth(), fromDate.getDate() + 6, 23, 59, 59)
    groupBy = 'day'
  } else if (filterPeriod.value === 'month') {
    fromDate = new Date(now.getFullYear(), now.getMonth(), 1)
    toDate = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59)
    groupBy = 'day'
  } else if (filterPeriod.value === 'year') {
    fromDate = new Date(now.getFullYear(), 0, 1)
    toDate = new Date(now.getFullYear(), 11, 31, 23, 59, 59)
    groupBy = 'month'
  }

  const toLocalISO = (d) => {
    if (!d) return null
    const pad = n => n < 10 ? '0' + n : n
    return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`
  }

  return { FromDate: toLocalISO(fromDate), ToDate: toLocalISO(toDate), GroupBy: groupBy }
}

const updateChartsData = (data) => {
  totalRevenue.value = data.totalRevenue || 0
  orderCount.value = data.completedOrdersCount || 0
  averageOrderValue.value = data.averageOrderValue || 0

  if (data.revenueChart) {
    revenueOptions.value = {
      ...revenueOptions.value,
      xaxis: { ...revenueOptions.value.xaxis, categories: data.revenueChart.map(x => x.timeLabel) }
    }
    revenueSeries.value = [{ name: 'Doanh thu', data: data.revenueChart.map(x => x.amount) }]
  }

  if (data.packageSales) {
    const sortedPackages = [...data.packageSales].sort((a, b) => b.quantitySold - a.quantitySold)
    packageSalesData.value = sortedPackages

    const top5 = sortedPackages.slice(0, 5)
    topProductsOptions.value = {
      ...topProductsOptions.value,
      xaxis: { ...topProductsOptions.value.xaxis, categories: top5.map(x => x.packageName) }
    }
    topProductsSeries.value = [{ name: 'Đã bán', data: top5.map(x => x.quantitySold) }]
  }
}

const fetchStats = async () => {
  isLoading.value = true
  try {
    const filters = getDateFilter()
    const params = new URLSearchParams()

    if (filters.FromDate) params.append('FromDate', filters.FromDate)
    if (filters.ToDate) params.append('ToDate', filters.ToDate)
    params.append('GroupBy', filters.GroupBy)

    const response = await apiClient.get(`/Static/revenue-details?${params.toString()}`)
    const data = response.data.data || response.data

    updateChartsData(data)
  } catch (error) {
    console.error('Lỗi khi tải dữ liệu thống kê:', error)
  } finally {
    isLoading.value = false
  }
}

watch(filterPeriod, () => fetchStats())
onMounted(() => { fetchStats() })
</script>

<template>
  <div class="p-4">
    <!-- Header -->
    <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-between mb-4">
      <div>
        <h1 class="fs-5 fw-bold text-dark mb-0">Thống kê</h1>
        <p class="small text-muted mt-1 mb-0">
          Tổng quan tình hình kinh doanh của FreshFarm
        </p>
      </div>
      <div class="mt-3 mt-md-0 d-flex align-items-center gap-2">
        <!-- Tab buttons inline -->
        <div class="btn-group btn-group-sm" role="group">
          <button @click="currentTab = 'revenue'" type="button"
            class="btn" style="border-radius: 0 !important;"
            :class="currentTab === 'revenue' ? 'btn-success' : 'btn-outline-secondary'">
            Doanh thu
          </button>
          <button @click="currentTab = 'products'" type="button"
            class="btn" style="border-radius: 0 !important;"
            :class="currentTab === 'products' ? 'btn-success' : 'btn-outline-secondary'">
            Sản phẩm bán chạy
          </button>
        </div>
        <select v-model="filterPeriod" class="form-select form-select-sm" style="width:auto; border-radius: 0 !important;">
          <option value="today">Hôm nay</option>
          <option value="week">Tuần này</option>
          <option value="month">Tháng này</option>
          <option value="year">Năm nay</option>
        </select>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="isLoading" class="text-center py-5">
      <div class="spinner-border text-success" role="status">
        <span class="visually-hidden">Đang tải...</span>
      </div>
    </div>

    <!-- Main Content -->
    <div v-else class="w-100">
      <!-- TAB 1: DOANH THU -->
      <template v-if="currentTab === 'revenue'">
        <!-- Summary Cards -->
        <div class="row row-cols-1 row-cols-md-3 g-3 mb-4">
          <div class="col" v-for="item in summary" :key="item.id">
            <div class="bg-white border p-3 d-flex align-items-center justify-content-between"
              style="border-color: #e5e7eb !important; border-radius: 0 !important;">
              <div>
                <p class="small text-muted fw-medium mb-1">{{ item.name }}</p>
                <p class="fw-bold text-dark mb-0" style="font-size:1.15rem;">{{ item.value }}</p>
              </div>
              <div :class="['d-flex align-items-center justify-content-center flex-shrink-0', item.bg, item.color]"
                style="width:48px; height:48px; border-radius: 0 !important;">
                <component :is="item.icon" style="width:24px;height:24px;" />
              </div>
            </div>
          </div>
        </div>

        <!-- Revenue Chart -->
        <div class="bg-white border p-4" style="border-color: #e5e7eb !important; border-radius: 0 !important;">
          <div class="d-flex align-items-center justify-content-between mb-3">
            <h2 class="fw-bold text-dark mb-0" style="font-size: 0.875rem;">Biểu đồ doanh thu</h2>
          </div>
          <VueApexCharts type="area" height="350" :options="revenueOptions" :series="revenueSeries" />
        </div>
      </template>

      <!-- TAB 2: SẢN PHẨM BÁN CHẠY -->
      <template v-if="currentTab === 'products'">
        <div class="row g-3">
          <!-- Chart -->
          <div class="col-12 col-lg-6">
            <div class="bg-white border p-4" style="border-color: #e5e7eb !important; border-radius: 0 !important;">
              <h2 class="fw-bold text-dark mb-3" style="font-size: 0.875rem;">Top 5 sản phẩm bán chạy</h2>
              <VueApexCharts type="bar" height="350" :options="topProductsOptions" :series="topProductsSeries" />
            </div>
          </div>
          <!-- Table -->
          <div class="col-12 col-lg-6">
            <div class="bg-white border p-4 d-flex flex-column"
              style="border-color: #e5e7eb !important; border-radius: 0 !important; max-height: 440px;">
              <h2 class="fw-bold text-dark mb-3" style="font-size: 0.875rem;">Bảng xếp hạng theo số lượng</h2>
              <div class="overflow-auto flex-grow-1">
                <table class="table table-hover ff-table mb-0">
                  <thead class="sticky-top">
                    <tr>
                      <th>STT</th>
                      <th>Tên sản phẩm (Gói)</th>
                      <th class="text-end">Đã bán</th>
                      <th class="text-end">Doanh thu</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="(item, idx) in packageSalesData" :key="item.packageId">
                      <td class="text-muted fw-medium">{{ idx + 1 }}</td>
                      <td class="fw-medium text-dark">{{ item.packageName }}</td>
                      <td class="text-end fw-bold text-success">{{ item.quantitySold }}</td>
                      <td class="text-end text-muted">{{ formatPrice(item.totalAmount) }}</td>
                    </tr>
                    <tr v-if="!packageSalesData || packageSalesData.length === 0">
                      <td colspan="4" class="text-center py-4 text-muted">Không có dữ liệu</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </template>
    </div>
  </div>
</template>
