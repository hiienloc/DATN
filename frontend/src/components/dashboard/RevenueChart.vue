<template>
  <div class="card">
    <div class="d-flex align-items-start justify-content-between mb-4">
      <div>
        <h3 class="small fw-semibold text-dark mb-1">Biểu đồ doanh thu tuần</h3>
        <p class="small text-muted mb-0">Dữ liệu cập nhật thời gian thực</p>
      </div>
      <div class="btn-group" role="group" style="background: #f3f4f6; border-radius: 0.5rem; padding: 0.25rem; display: inline-flex; gap: 0.125rem;">
        <button
          v-for="tab in tabs"
          :key="tab.key"
          @click="activeTab = tab.key"
          class="btn btn-sm px-2 py-1"
          :class="activeTab === tab.key
            ? 'btn-light'
            : 'btn-link text-muted'"
          style="font-size: 0.75rem; font-weight: 500;"
        >
          {{ tab.label }}
        </button>
      </div>
    </div>

    <!-- Bars -->
    <div class="d-flex align-items-end gap-1" style="height: 10rem;">
      <div
        v-for="(d, i) in currentData"
        :key="d.day"
        class="d-flex flex-column align-items-center gap-1 flex-grow-1"
      >
        <div class="w-100" style="display: flex; align-items: flex-end;">
          <div
            class="w-100 transition-all"
            :class="i === highlightIndex ? 'bg-success' : ''"
            :style="{
              height: barHeight(d.val) + 'px',
              backgroundColor: i === highlightIndex ? '#4e7c66' : '#86efac',
              borderRadius: '0.375rem 0.375rem 0 0',
              cursor: 'pointer'
            }"
            :title="formatMoney(d.val)"
          ></div>
        </div>
        <span class="small text-muted" style="white-space: nowrap; font-size: 0.6875rem;">{{ d.day }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import apiClient from '@/api/axios'

const activeTab = ref('week')
const tabs = [
  { key: 'week',  label: '7 ngày qua' },
  { key: 'month', label: 'Tháng này' },
]

const liveData = ref([])

const fetchChartData = async () => {
  try {
    const now = new Date()
    let fromDate = null
    const toDate = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59)
    
    if (activeTab.value === 'week') {
      fromDate = new Date()
      fromDate.setDate(now.getDate() - 6)
      fromDate.setHours(0, 0, 0, 0)
    } else {
      fromDate = new Date(now.getFullYear(), now.getMonth(), 1)
      fromDate.setHours(0, 0, 0, 0)
    }
    
    const toLocalISO = (d) => {
      const pad = n => n < 10 ? '0' + n : n
      return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`
    }
    
    const response = await apiClient.get(`/Static/revenue-details`, {
      params: {
        FromDate: toLocalISO(fromDate),
        ToDate: toLocalISO(toDate),
        GroupBy: 'day'
      }
    })
    
    const responseData = response.data?.data || response.data
    const chartRes = responseData?.revenueChart || []
    
    liveData.value = chartRes.map(x => ({
      day: x.timeLabel,
      val: x.amount || 0
    }))
    
    if (liveData.value.length === 0) {
      liveData.value = [{ day: 'N/A', val: 0 }]
    }
  } catch (error) {
    console.error('Lỗi khi tải dữ liệu biểu đồ:', error)
  }
}

watch(activeTab, () => {
  fetchChartData()
})

onMounted(() => {
  fetchChartData()
})

const currentData = computed(() => liveData.value)

const highlightIndex = computed(() => {
  const vals = currentData.value.map(d => d.val)
  const max = Math.max(...vals)
  if (max === 0) return -1
  return vals.indexOf(max)
})

const maxVal = computed(() => {
  const max = Math.max(...currentData.value.map(d => d.val))
  return max > 0 ? max : 100000 // Tránh chia cho 0
})

function barHeight(val) {
  return Math.round((val / maxVal.value) * 140)
}

function formatMoney(val) {
  if (val >= 1000000) {
    return (val / 1000000).toLocaleString('vi-VN', { maximumFractionDigits: 1 }) + 'M ₫'
  }
  return new Intl.NumberFormat('vi-VN').format(val) + ' ₫'
}
</script>
