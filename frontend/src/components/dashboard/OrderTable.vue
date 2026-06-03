<template>
  <div class="card">
    <div class="flex items-start justify-content-between mb-5">
      <div>
        <h3 class="text-sm font-semibold text-gray-800">Đơn hàng gần đây</h3>
        <p class="text-xs text-gray-400 mt-0.5">Quản lý và cập nhật tiến độ giao hàng</p>
      </div>
      <button class="text-xs text-green-600 font-medium hover:underline">Xem chi tiết tất cả →</button>
    </div>

    <table class="w-full border-collapse">
      <thead>
        <tr>
          <th v-for="col in columns" :key="col"
              class="text-left px-3 py-2 text-[11px] font-semibold text-gray-400 uppercase tracking-wider border-b border-gray-200">
            {{ col }}
          </th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="order in orders"
          :key="order.code"
          class="hover:bg-gray-50 "
        >
          <td class="px-3 py-3.5 border-b border-gray-100">
            <span class="font-mono text-xs text-green-600 font-semibold">{{ order.code }}</span>
          </td>
          <td class="px-3 py-3.5 border-b border-gray-100">
            <div class="d-flex align-items-center gap-2">
              <div class="w-7 h-7 rounded-full bg-green-100 text-green-700 text-xs font-semibold d-flex align-items-center justify-content-center flex-shrink-0">
                {{ order.initials }}
              </div>
              <span class="text-sm font-medium text-gray-700">{{ order.customer }}</span>
            </div>
          </td>
          <td class="px-3 py-3.5 border-b border-gray-100 text-sm text-gray-600">{{ order.product }}</td>
          <td class="px-3 py-3.5 border-b border-gray-100">
            <span class="text-sm font-semibold text-gray-800">{{ order.amount }}</span>
          </td>
          <td class="px-3 py-3.5 border-b border-gray-100">
            <span class="status-pill" :class="statusClass(order.status)">
              {{ statusLabel(order.status) }}
            </span>
          </td>
          <td class="px-3 py-3.5 border-b border-gray-100">
            <button class="w-7 h-7 rounded-md border border-gray-200 d-flex align-items-center justify-content-center text-gray-400 hover:bg-gray-100 hover:text-gray-600 transition-all">
              <EllipsisVerticalIcon class="w-4 h-4" />
            </button>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { EllipsisVerticalIcon } from '@heroicons/vue/24/outline'
import apiClient from '@/api/axios'

const columns = ['Mã đơn', 'Khách hàng', 'Sản phẩm / Combo', 'Tổng thanh toán', 'Trạng thái', '']
const orders = ref([])

const getInitials = (name) => {
  if (!name) return '?'
  const words = name.split(' ')
  if (words.length === 1) return words[0].substring(0, 2).toUpperCase()
  return (words[0].charAt(0) + words[words.length - 1].charAt(0)).toUpperCase()
}

const formatPrice = (val) => new Intl.NumberFormat('vi-VN').format(val || 0) + ' ₫'

const fetchRecentOrders = async () => {
  try {
    const response = await apiClient.get('/Order')
    const data = response.data?.data || response.data || []
    // Sắp xếp đơn mới nhất lên trên và lấy 5 đơn
    const sorted = data.sort((a, b) => {
      const dateA = a.orderDate ? new Date(a.orderDate) : 0
      const dateB = b.orderDate ? new Date(b.orderDate) : 0
      return dateB - dateA
    })
    orders.value = sorted.slice(0, 5).map(o => {
      const comboNames = o.items && o.items.length > 0 
        ? o.items.map(i => i.packageName).join(', ') 
        : 'Nông sản tổng hợp'
        
      // Tính toán tổng cộng có bù 25k cho đồng nhất
      const subtotal = o.items?.reduce((acc, i) => acc + (i.orderPrice * i.orderQuantity), 0) || 0
      const finalAmount = Math.max(o.totalAmount || 0, subtotal + 25000)

      return {
        code: o.orderCode || `#${o.orderId}`,
        customer: o.receiveName || 'Khách hàng',
        initials: getInitials(o.receiveName),
        product: comboNames.length > 35 ? comboNames.substring(0, 35) + '...' : comboNames,
        amount: formatPrice(finalAmount),
        status: o.orderStatus
      }
    })
  } catch (error) {
    console.error('Lỗi khi tải đơn hàng gần đây:', error)
  }
}

onMounted(() => {
  fetchRecentOrders()
})

const statusMap = {
  'Chờ xác nhận': { label: 'Chờ xử lý', class: 'bg-warning bg-opacity-10 text-warning fw-semibold' },
  'Đã xác nhận': { label: 'Đã xác nhận', class: 'bg-primary bg-opacity-10 text-primary fw-semibold' },
  'Confirmed': { label: 'Đã xác nhận', class: 'bg-primary bg-opacity-10 text-primary fw-semibold' },
  'Đang giao hàng': { label: 'Đang giao', class: 'bg-info bg-opacity-10 text-info fw-semibold' },
  'Hoàn thành': { label: 'Hoàn thành', class: 'bg-success bg-opacity-10 text-success fw-semibold' },
  'Đã hủy': { label: 'Đã hủy', class: 'bg-danger bg-opacity-10 text-danger fw-semibold' },
}

function statusLabel(s) { return statusMap[s]?.label ?? s }
function statusClass(s) { return statusMap[s]?.class ?? 'bg-secondary bg-opacity-10 text-secondary' }
</script>
