<script setup>
import { computed } from 'vue'
import VueApexCharts from 'vue3-apexcharts'

const props = defineProps({
  salesHistory: { type: Array, default: () => [] },
  exportHistory: { type: Array, default: () => [] },
  forecastData: { type: Array, required: true }, // [{ date, value }]
  unit: { type: String, default: '' }
})

const categories = computed(() => {
  const maxLen = Math.max(props.salesHistory.length, props.exportHistory.length)
  const labels = []
  const today = new Date()
  
  // Tạo nhãn ngày (ngày/tháng) lùi dần từ ngày hiện tại
  for (let i = maxLen - 1; i >= 0; i--) {
    const d = new Date()
    d.setDate(today.getDate() - i)
    labels.push(`${d.getDate()}/${d.getMonth() + 1}`)
  }
  
  return labels.concat(props.forecastData.map(d => d.date))
})

const salesSeries = computed(() => {
  const maxLen = Math.max(props.salesHistory.length, props.exportHistory.length)
  const diff = maxLen - props.salesHistory.length
  return Array(diff).fill(null).concat(props.salesHistory)
})

const exportSeries = computed(() => {
  const maxLen = Math.max(props.salesHistory.length, props.exportHistory.length)
  const diff = maxLen - props.exportHistory.length
  return Array(diff).fill(null).concat(props.exportHistory)
})

const forecastSeries = computed(() => {
  const maxLen = Math.max(props.salesHistory.length, props.exportHistory.length)
  return Array(maxLen).fill(null).concat(props.forecastData.map(d => d.value))
})

const chartOptions = computed(() => ({
  chart: { type: 'line', height: 320, toolbar: { show: false }, fontFamily: 'inherit' },
  stroke: { curve: 'smooth', width: 3 },
  colors: ['#10b981', '#3b82f6', '#f59e0b'],
  dataLabels: { enabled: false },
  xaxis: { categories: categories.value, labels: { rotate: -45 } },
  yaxis: { labels: { formatter: v => v != null ? v + (props.unit ? ' ' + props.unit : '') : '' } },
  legend: { show: true, position: 'top', horizontalAlign: 'right' },
  tooltip: { shared: true },
  grid: { borderColor: '#f3f4f6', strokeDashArray: 4 }
}))
</script>

<template>
  <VueApexCharts
    type="line"
    height="320"
    :options="chartOptions"
    :series="[
      { name: 'Tiêu thụ (Đơn hoàn thành)', data: salesSeries },
      { name: 'Xuất kho thực tế', data: exportSeries },
      { name: 'Dự báo AI', data: forecastSeries }
    ]"
  />
</template>

