<template>
  <div class="dashboard-container fade-in-up">
    <!-- Header -->
    <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center gap-3 mb-4">
      <div>
        <h1 class="fs-4 fw-bold text-dark mb-1">{{ greeting }}, Admin </h1>
        <p class="text-secondary small mb-0">
          Hôm nay trang trại có
          <span class="text-success fw-bold">{{ pendingOrders }} đơn hàng mới</span>
          đang chờ bạn xác nhận và xử lý.
        </p>
      </div>
      <button 
        @click="refreshAll" 
        :disabled="chartLoading || ordersLoading"
        class="btn btn-light d-flex align-items-center gap-2 border px-3 py-2 rounded-3 hover-scale transition-all shadow-sm bg-white text-secondary small font-medium"
      >
        <ArrowPathIcon :class="{ 'animate-spin': chartLoading || ordersLoading }" style="width: 16px; height: 16px;" />
        Làm mới dữ liệu
      </button>
    </div>

    <!-- Stat cards -->
    <div class="row row-cols-1 row-cols-sm-2 row-cols-xl-4 g-4 mb-4">
      <div class="col" v-for="(stat, index) in stats" :key="stat.label">
        <div 
          class="card ff-stat-card border-0 h-100 position-relative overflow-hidden" 
          :style="{ animationDelay: `${index * 0.08}s`, '--stat-color': stat.color }"
        >
          <!-- Background Accent Glow -->
          <div class="stat-card-glow" :style="{ backgroundColor: stat.color }"></div>
          
          <div class="card-body d-flex align-items-center justify-content-between p-4 position-relative z-1">
            <div class="d-flex flex-column">
              <span class="text-secondary small mb-1 font-medium">{{ stat.label }}</span>
              <span class="fw-bold fs-3 text-dark mb-2 tracking-tight" :class="{ 'text-danger': stat.danger }">
                {{ stat.value }}
              </span>
              <span 
                class="badge ff-stat-badge align-self-start"
                :style="{ backgroundColor: stat.bgColor, color: stat.color }"
              >
                {{ stat.badge }}
              </span>
            </div>
            
            <div 
              class="stat-icon-box d-flex align-items-center justify-content-center"
              :style="{ backgroundColor: stat.bgColor, color: stat.color }"
            >
              <component :is="stat.icon" style="width: 24px; height: 24px; stroke-width: 1.8;" />
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Chart + Notifications -->
    <div class="row g-4 mb-4">
      <!-- Revenue Chart -->
      <div class="col-12 col-xl-8">
        <div class="card ff-chart-card border-0 h-100 shadow-sm rounded-4">
          <div class="card-body p-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
              <div>
                <h5 class="fw-bold text-dark mb-1 small-title">Biểu đồ doanh thu</h5>
                <p class="text-muted small mb-0">Theo dõi nguồn doanh thu bán nông sản</p>
              </div>
              <select class="form-select form-select-sm w-auto ff-select rounded-3 py-1.5 px-3" v-model="groupBy" @change="fetchRevenueChart">
                <option value="day">Theo ngày</option>
                <option value="month">Theo tháng</option>
              </select>
            </div>
            
            <div v-if="chartLoading" class="text-center py-5 my-4 text-muted">
              <div class="spinner-border text-success" role="status" style="width: 2rem; height: 2rem;">
                <span class="visually-hidden">Đang tải...</span>
              </div>
              <p class="small mt-2">Đang xử lý biểu đồ doanh thu...</p>
            </div>
            <div v-show="!chartLoading" class="chart-wrapper">
               <canvas ref="chartCanvas"></canvas>
            </div>
          </div>
        </div>
      </div>

      <!-- Notifications -->
      <div class="col-12 col-xl-4">
        <div class="card ff-notification-card border-0 h-100 shadow-sm rounded-4">
          <div class="card-body p-4 d-flex flex-column">
            <div class="mb-4">
              <h5 class="fw-bold text-dark mb-1 small-title">Thông báo hệ thống</h5>
              <p class="text-muted small mb-0">Hoạt động cần xử lý ngay</p>
            </div>
            
            <div class="notification-list d-flex flex-column gap-3 flex-grow-1 justify-content-center">
              <!-- Warning: Low stock count -->
              <div 
                v-if="lowStockCount > 0" 
                @click="goToLowStock"
                class="notification-item p-3 d-flex gap-3 align-items-center cursor-pointer transition-all border-start border-4 rounded-3 border-danger"
                style="background-color: #fef2f2;"
              >
                <div class="notification-icon-box bg-white text-danger shadow-sm rounded-circle d-flex align-items-center justify-content-center">
                  <ExclamationTriangleIcon style="width: 18px; height: 18px;" />
                </div>
                <div class="flex-grow-1">
                  <div class="fw-bold text-danger small">Hết hàng / Sắp hết hàng</div>
                  <div class="text-secondary small mt-0.5">
                    Có {{ lowStockCount }} sản phẩm tồn kho chạm mức tối thiểu.
                  </div>
                </div>
                <ArrowRightIcon style="width: 14px; height: 14px;" class="text-secondary arrow-icon" />
              </div>

              <!-- Pending Orders notification -->
              <div 
                v-if="pendingOrders > 0" 
                @click="goToOrders"
                class="notification-item p-3 d-flex gap-3 align-items-center cursor-pointer transition-all border-start border-4 rounded-3 border-warning"
                style="background-color: #fffbeb;"
              >
                <div class="notification-icon-box bg-white text-warning shadow-sm rounded-circle d-flex align-items-center justify-content-center">
                  <BellIcon style="width: 18px; height: 18px;" />
                </div>
                <div class="flex-grow-1">
                  <div class="fw-bold text-warning-dark small">Đơn chờ xác nhận</div>
                  <div class="text-secondary small mt-0.5">
                    Có {{ pendingOrders }} đơn hàng chưa được xác nhận xử lý.
                  </div>
                </div>
                <ArrowRightIcon style="width: 14px; height: 14px;" class="text-secondary arrow-icon" />
              </div>

              <!-- Clean Empty State -->
              <div 
                v-if="pendingOrders === 0 && lowStockCount === 0"
                class="text-center py-5 d-flex flex-column align-items-center justify-content-center h-100 flex-grow-1"
              >
                <div class="empty-icon-box mb-3 d-flex align-items-center justify-content-center">
                  <InboxIcon style="width: 48px; height: 48px; color: #cbd5e1;" />
                </div>
                <h6 class="fw-semibold text-dark mb-1">Mọi thứ đều ổn!</h6>
                <p class="text-secondary small mb-0">Hệ thống đang hoạt động trơn tru,<br>không có cảnh báo mới.</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Orders Table -->
    <div class="card ff-table-card border-0 shadow-sm rounded-4 overflow-hidden">
      <div class="card-body p-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
          <div>
            <h5 class="fw-bold text-dark mb-1 small-title">Đơn hàng mới nhất</h5>
            <p class="text-muted small mb-0">Danh sách 5 đơn hàng vừa phát sinh trên hệ thống</p>
          </div>
          <button @click="goToOrders" class="btn btn-sm btn-light text-success fw-semibold ff-btn-outline px-3 py-2 rounded-3 shadow-sm border transition-all">
            Xem tất cả đơn →
          </button>
        </div>
        
        <div v-if="ordersLoading" class="text-center py-5 text-muted">
           <div class="spinner-border text-success" role="status">
              <span class="visually-hidden">Đang tải...</span>
           </div>
           <p class="small mt-2 mb-0">Đang đồng bộ đơn hàng mới nhất...</p>
        </div>
        
        <div v-else-if="orders.length === 0" class="text-center text-muted py-5 small border rounded-3 bg-light bg-opacity-50">
          Không có đơn hàng nào vừa phát sinh
        </div>
        
        <div v-else class="table-responsive">
          <table class="table ff-table align-middle mb-0">
            <thead>
              <tr>
                <th class="ps-3 border-0 text-muted fw-semibold small text-uppercase">Mã đơn</th>
                <th class="border-0 text-muted fw-semibold small text-uppercase">Khách hàng</th>
                <th class="border-0 text-muted fw-semibold small text-uppercase">Ngày đặt</th>
                <th class="text-end border-0 text-muted fw-semibold small text-uppercase">Tổng tiền</th>
                <th class="text-center pe-3 border-0 text-muted fw-semibold small text-uppercase">Trạng thái</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="o in orders" :key="o.orderId" class="ff-table-row">
                <td class="ps-3 fw-bold text-dark">
                  <span class="text-secondary opacity-70">#</span>{{ o.orderCode || o.orderId }}
                </td>
                <td>
                  <div class="d-flex align-items-center gap-3">
                     <div class="avatar-placeholder d-flex align-items-center justify-content-center fw-bold shadow-sm" :style="{ backgroundColor: getAvatarColor(o.receiveName || o.customerName) }">
                        {{ (o.receiveName || o.customerName || 'U').charAt(0).toUpperCase() }}
                     </div>
                     <span class="fw-semibold text-dark" style="font-size: 0.9rem;">{{ o.receiveName || o.customerName }}</span>
                  </div>
                </td>
                <td class="text-secondary" style="font-size: 0.85rem;">{{ formatDate(o.orderDate) }}</td>
                <td class="text-end fw-bold text-success" style="font-size: 0.95rem;">{{ formatPrice(o.totalAmount) }}</td>
                <td class="text-center pe-3">
                  <span class="badge status-pill" :class="statusClass(o.orderStatus)">
                    {{ statusLabel(o.orderStatus) }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { Chart, registerables } from 'chart.js'
import apiClient from '@/api/axios'
import {
  BellIcon,
  BanknotesIcon,
  UsersIcon,
  ExclamationTriangleIcon,
  InboxIcon,
  ArrowRightIcon,
  ArrowPathIcon
} from '@heroicons/vue/24/outline'

const emit = defineEmits(['nav-change'])

Chart.register(...registerables)

// ── State ──────────────────────────────────────────────────────────────────
const pendingOrders  = ref(0)
const revenueMonth   = ref(0)
const totalCustomers = ref(0)
const lowStockCount  = ref(0)

const groupBy     = ref('day')
const chartLoading = ref(false)
const chartCanvas  = ref(null)
let chartInstance  = null

const orders       = ref([])
const ordersLoading = ref(false)

// ── Computed & Helpers ─────────────────────────────────────────────────────
const greeting = computed(() => {
  const hour = new Date().getHours()
  if (hour < 12) return 'Chào buổi sáng'
  if (hour < 18) return 'Chào buổi chiều'
  return 'Chào buổi tối'
})

const formatPrice = (v) => v >= 1e6
  ? (v / 1e6).toLocaleString('vi-VN', { maximumFractionDigits: 1 }) + 'M đ'
  : new Intl.NumberFormat('vi-VN').format(v || 0) + ' đ'

const formatDate = (d) => {
  if (!d) return '-'
  const date = new Date(d)
  return date.toLocaleString('vi-VN', {
    hour: '2-digit',
    minute: '2-digit',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric'
  })
}

const statusClass = (s) => {
  const statusMap = {
    'Chờ xác nhận': 'badge-warning',
    'Đã xác nhận':  'badge-info',
    'Confirmed':    'badge-info',
    'Đang giao':    'badge-info',
    'Hoàn thành':   'badge-success',
    'Đã hủy':       'badge-danger',
  }
  return statusMap[s] || 'badge-secondary'
}

const statusLabel = (s) => {
  if (!s) return 'N/A'
  if (s === 'Confirmed') return 'Đã xác nhận'
  return s
}

// Custom avatar colors for a premium, playful look
const getAvatarColor = (name) => {
  if (!name) return '#e2e8f0'
  const colors = [
    '#fef3c7', // Amber
    '#dcfce7', // Green
    '#dbeafe', // Blue
    '#f3e8ff', // Purple
    '#ffe4e6', // Rose
    '#e0f2fe'  // Sky
  ]
  const textColors = [
    '#d97706',
    '#155724',
    '#1d4ed8',
    '#6b21a8',
    '#be123c',
    '#0369a1'
  ]
  let hash = 0
  for (let i = 0; i < name.length; i++) {
    hash = name.charCodeAt(i) + ((hash << 5) - hash)
  }
  const index = Math.abs(hash) % colors.length
  return colors[index]
}

// ── Stat cards config ──────────────────────────────────────────────────────
const stats = computed(() => [
  { 
    label: 'Đơn chờ xử lý',  
    value: pendingOrders.value.toString(),  
    badge: 'Cần duyệt', 
    icon: BellIcon, 
    color: '#d97706', // amber
    bgColor: '#fffbeb', 
    danger: false 
  },
  { 
    label: 'Doanh thu tháng', 
    value: formatPrice(revenueMonth.value), 
    badge: 'Đầu tháng đến nay',  
    icon: BanknotesIcon, 
    color: '#16a34a', // green
    bgColor: '#f0fdf4', 
    danger: false 
  },
  { 
    label: 'Khách đăng ký', 
    value: totalCustomers.value.toString(), 
    badge: 'Thành viên mới',    
    icon: UsersIcon, 
    color: '#2563eb', // blue
    bgColor: '#eff6ff', 
    danger: false 
  },
  { 
    label: 'Tồn kho cảnh báo',    
    value: lowStockCount.value.toString(),  
    badge: 'Cần bổ sung',  
    icon: ExclamationTriangleIcon, 
    color: '#dc2626', // red
    bgColor: '#fef2f2', 
    danger: lowStockCount.value > 0 
  },
])

// ── Navigation ─────────────────────────────────────────────────────────────
const goToLowStock = () => {
  emit('nav-change', { page: 'inventory', filter: 'low' })
}

const goToOrders = () => {
  emit('nav-change', 'order')
}

// ── Fetch Operations ───────────────────────────────────────────────────────
const fetchDashboard = async () => {
  try {
    const res  = await apiClient.get('/Static/dashboard')
    const data = res.data?.data || res.data
    pendingOrders.value  = data.pendingOrdersCount || 0
    revenueMonth.value   = data.revenueMonth       || 0
    totalCustomers.value = data.totalCustomersCount || 0
    lowStockCount.value  = data.lowStockCount       || 0
  } catch (e) {
    console.error('Dashboard error:', e)
  }
}

const fetchRevenueChart = async () => {
  chartLoading.value = true
  try {
    const res  = await apiClient.get('/Static/revenue-details', {
      params: { groupBy: groupBy.value }
    })
    const data = res.data?.data || res.data
    renderChart(data.revenueChart || [])
  } catch (e) {
    console.error('Chart error:', e)
  } finally {
    chartLoading.value = false
  }
}

const renderChart = (items) => {
  if (chartInstance) chartInstance.destroy()
  if (!chartCanvas.value) return

  const ctx = chartCanvas.value.getContext('2d')
  
  // Create beautiful gradient background fill
  const gradient = ctx.createLinearGradient(0, 0, 0, 300)
  gradient.addColorStop(0, 'rgba(46, 125, 50, 0.25)')
  gradient.addColorStop(1, 'rgba(46, 125, 50, 0.00)')

  chartInstance = new Chart(ctx, {
    type: 'line',
    data: {
      labels:   items.map(i => i.timeLabel),
      datasets: [{
        label:           'Doanh thu (đ)',
        data:            items.map(i => i.amount),
        backgroundColor: gradient,
        borderColor:     '#2E7D32',
        borderWidth:     3.5,
        fill:            true,
        tension:         0.4, // Smooth curve
        pointBackgroundColor: '#2E7D32',
        pointBorderColor:     '#ffffff',
        pointBorderWidth:     2,
        pointRadius:          4,
        pointHoverRadius:     7,
        pointHoverBackgroundColor: '#1b5e20',
        pointHoverBorderColor:     '#ffffff',
        pointHoverBorderWidth:     3,
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: { 
        legend: { display: false },
        tooltip: {
          backgroundColor: '#1f2937',
          titleColor: '#ffffff',
          bodyColor: '#e5e7eb',
          padding: 12,
          cornerRadius: 8,
          displayColors: false,
          callbacks: {
            label: function(context) {
              return 'Doanh thu: ' + new Intl.NumberFormat('vi-VN').format(context.parsed.y) + ' đ';
            }
          }
        }
      },
      scales: {
        x: {
          grid: { display: false },
          ticks: { font: { family: "'Be Vietnam Pro', sans-serif", size: 10.5, weight: '500' }, color: '#64748b' }
        },
        y: {
          grid: { color: '#f1f5f9', borderDash: [5, 5] },
          border: { display: false },
          ticks: {
            font: { family: "'Be Vietnam Pro', sans-serif", size: 10.5 },
            color: '#64748b',
            callback: v => v >= 1e6
              ? (v / 1e6).toFixed(1) + 'M'
              : new Intl.NumberFormat('vi-VN').format(v)
          }
        }
      },
      animation: {
        duration: 900,
        easing: 'easeOutQuart'
      }
    }
  })
}

const fetchOrders = async () => {
  ordersLoading.value = true
  try {
    const res = await apiClient.get('/Order?pageSize=100&page=1')
    const allOrders = res.data?.data || res.data?.items || res.data || []
    
    orders.value = allOrders
      .sort((a, b) => new Date(b.orderDate) - new Date(a.orderDate))
      .slice(0, 5)
  } catch (e) {
    console.error('Orders error:', e)
  } finally {
    ordersLoading.value = false
  }
}

const refreshAll = async () => {
  await Promise.all([
    fetchDashboard(),
    fetchRevenueChart(),
    fetchOrders()
  ])
}

// ── Init ───────────────────────────────────────────────────────────────────
onMounted(refreshAll)
</script>

<style scoped>
.dashboard-container {
  padding-bottom: 3rem;
  max-width: 1200px;
  margin: 0 auto;
}

.fade-in-up {
  animation: fadeInUp 0.45s cubic-bezier(0.16, 1, 0.3, 1) forwards;
}

@keyframes fadeInUp {
  from { opacity: 0; transform: translateY(16px); }
  to   { opacity: 1; transform: translateY(0); }
}

/* Stat Cards */
.ff-stat-card {
  border-radius: 16px !important;
  box-shadow: 0 4px 18px rgba(0, 0, 0, 0.025);
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
  background: white;
  border: 1px solid rgba(226, 232, 240, 0.8) !important;
  opacity: 0;
  animation: fadeInUp 0.5s cubic-bezier(0.16, 1, 0.3, 1) forwards;
}

.ff-stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 28px rgba(0, 0, 0, 0.06);
  border-color: var(--stat-color) !important;
}

/* Accent glow inside cards */
.stat-card-glow {
  position: absolute;
  top: -40px;
  right: -40px;
  width: 120px;
  height: 120px;
  border-radius: 50% !important;
  opacity: 0.03;
  filter: blur(20px);
  pointer-events: none;
  transition: all 0.35s ease;
}

.ff-stat-card:hover .stat-card-glow {
  opacity: 0.08;
  transform: scale(1.2);
}

.stat-icon-box {
  width: 50px;
  height: 50px;
  border-radius: 12px !important;
  transition: all 0.3s ease;
}

.ff-stat-card:hover .stat-icon-box {
  transform: scale(1.08) rotate(3deg);
}

.ff-stat-badge {
  font-size: 0.72rem;
  padding: 4px 10px;
  font-weight: 600;
  border-radius: 6px !important;
}

/* Containers */
.ff-chart-card,
.ff-notification-card,
.ff-table-card {
  border-radius: 16px !important;
  box-shadow: 0 4px 18px rgba(0, 0, 0, 0.025) !important;
  background: white;
  border: 1px solid rgba(226, 232, 240, 0.8) !important;
}

.small-title {
  font-size: 1.05rem;
  letter-spacing: -0.01em;
}

.chart-wrapper {
  position: relative;
  height: 310px;
  width: 100%;
}

/* Notifications */
.notification-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.notification-item {
  border: 1px solid rgba(226, 232, 240, 0.5);
  border-radius: 12px !important;
  transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.01);
}

.notification-item:hover {
  transform: translateX(5px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.03);
}

.notification-icon-box {
  width: 38px;
  height: 38px;
  flex-shrink: 0;
  border-radius: 50% !important;
}

.arrow-icon {
  opacity: 0.4;
  transition: all 0.2s ease;
}

.notification-item:hover .arrow-icon {
  opacity: 0.8;
  transform: translateX(2px);
}

.text-warning-dark {
  color: #b45309;
}

.empty-icon-box {
  width: 80px;
  height: 80px;
  background: #f8fafc;
  border-radius: 50% !important;
  border: 2px dashed #e2e8f0;
}

/* Tables */
.ff-table {
  width: 100%;
}

.ff-table thead th {
  padding: 12px 16px;
  background-color: #f8fafc !important;
  color: #64748b !important;
  font-size: 0.72rem;
  letter-spacing: 0.05em;
  font-weight: 700;
  border-bottom: 1px solid #e2e8f0;
}

.ff-table thead th:first-child {
  border-top-left-radius: 8px !important;
  border-bottom-left-radius: 8px !important;
}

.ff-table thead th:last-child {
  border-top-right-radius: 8px !important;
  border-bottom-right-radius: 8px !important;
}

.ff-table-row {
  transition: background-color 0.2s ease;
}

.ff-table-row td {
  padding: 14px 16px;
  border-bottom: 1px solid #f1f5f9;
  background: transparent;
}

.ff-table-row:hover td {
  background-color: #f8fafc;
}

.avatar-placeholder {
  width: 34px;
  height: 34px;
  border-radius: 50% !important;
  font-size: 0.85rem;
}

/* Badges */
.status-pill {
  padding: 5px 12px;
  font-weight: 600;
  font-size: 0.72rem;
  letter-spacing: 0.02em;
  border-radius: 9999px !important;
  display: inline-block;
}

.badge-warning { 
  background-color: #fffbeb !important; 
  color: #b45309 !important; 
  border: 1px solid #fde68a !important; 
}
.badge-info { 
  background-color: #eff6ff !important; 
  color: #1d4ed8 !important; 
  border: 1px solid #bfdbfe !important; 
}
.badge-success { 
  background-color: #f0fdf4 !important; 
  color: #15803d !important; 
  border: 1px solid #bbf7d0 !important; 
}
.badge-danger { 
  background-color: #fef2f2 !important; 
  color: #b91c1c !important; 
  border: 1px solid #fecaca !important; 
}
.badge-secondary { 
  background-color: #f8fafc !important; 
  color: #475569 !important; 
  border: 1px solid #e2e8f0 !important; 
}

/* Utilities */
.ff-select {
  border-color: #cbd5e1;
  background-color: #ffffff;
  cursor: pointer;
  font-size: 0.85rem;
  font-weight: 500;
  color: #334155;
  transition: all 0.2s ease;
}

.ff-select:focus {
  border-color: #2E7D32;
  box-shadow: 0 0 0 3px rgba(46, 125, 50, 0.12);
}

.ff-btn-outline {
  background-color: #ffffff;
  color: #334155 !important;
  border-color: #cbd5e1 !important;
  font-size: 0.82rem;
}

.ff-btn-outline:hover {
  background-color: #2E7D32 !important;
  color: white !important;
  border-color: #2E7D32 !important;
}

.font-medium {
  font-weight: 500;
}
</style>