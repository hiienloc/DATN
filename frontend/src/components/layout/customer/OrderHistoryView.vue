<script setup>
import { ref, computed, onMounted } from 'vue'
import {
  ClockIcon,
  TruckIcon,
  CheckCircleIcon,
  XCircleIcon,
  EyeIcon,
  ChevronDownIcon,
  ExclamationTriangleIcon
} from '@heroicons/vue/24/outline'
import apiClient from '@/api/axios'
import { toast } from '@/utils/toast'

const emit = defineEmits(['navigate'])

const orders = ref([])
const loadingOrders = ref(false)

// Map backend status values to our UI keys
const mapStatus = (s) => {
  if (!s) return 'pending'
  const v = s.toLowerCase()
  if (v.includes('giao') || v === 'shipping' || v === 'delivering') return 'shipping'
  if (v.includes('hoàn') || v === 'delivered' || v === 'completed') return 'delivered'
  if (v.includes('hủy') || v === 'cancelled' || v === 'canceled') return 'cancelled'
  return 'pending'
}

const BASE_URL = import.meta.env.VITE_API_URL || window.location.origin

function getImageUrl(url) {
  if (!url) return 'https://images.unsplash.com/photo-1540420773420-3366772f4999?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80';
  if (url.startsWith('http')) return url;
  return `${BASE_URL}${url.startsWith('/') ? '' : '/'}${url}`;
}

const getUserIdFromToken = () => {
  const token = localStorage.getItem('token')
  if (!token) return null
  try {
    const base64Url = token.split('.')[1]
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/')
    const payload = JSON.parse(decodeURIComponent(atob(base64).split('').map(c => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2)).join('')))
    return payload["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"] || payload["nameid"] || payload["id"] || payload["sub"]
  } catch { return null }
}

const fetchOrders = async () => {
  loadingOrders.value = true
  const userId = getUserIdFromToken()
  
  try {
    const res = await apiClient.get(`/Order/user/${userId}`)
    const raw = res.data.data || res.data || []
    orders.value = raw.map(o => ({
      id: o.orderId || o.id,
      orderCode: o.orderCode,
      date: o.orderDate ? new Date(o.orderDate).toLocaleDateString('vi-VN') : '',
      status: mapStatus(o.orderStatus || o.status),
      total: o.totalAmount || 0,
      shipmentPrice: o.shipmentPrice ?? 0,
      items: (o.orderItems || []).map(i => ({
        name: i.packageName ?? 'Sản phẩm',
        qty: i.quantity ?? 1,
        price: i.unitPrice ?? 0,
        image: getImageUrl(i.imageUrl)
      }))
    }))
  } catch (e) {
    console.error('Lỗi tải đơn hàng phương án 1:', e)
    try {
      const res2 = await apiClient.get(`/Order?userId=${userId}`)
      const raw2 = res2.data.data || res2.data || []
      orders.value = raw2.map(o => ({
        id: o.orderId || o.id,
        orderCode: o.orderCode,
        date: o.orderDate ? new Date(o.orderDate).toLocaleDateString('vi-VN') : '',
        status: mapStatus(o.orderStatus || o.status),
        total: o.totalAmount || 0,
        shipmentPrice: o.shipmentPrice ?? 0,
        items: (o.orderItems || []).map(i => ({
          name: i.packageName ?? 'Sản phẩm',
          qty: i.quantity ?? 1,
          price: i.unitPrice ?? 0,
          image: getImageUrl(i.imageUrl)
        }))
      }))
    } catch (e2) {
      console.error('Lỗi tải đơn hàng phương án 2:', e2)
    }
  } finally {
    loadingOrders.value = false
  }
}

const expandedOrder = ref(null)
const cancellingOrderId = ref(null)
const showCancelConfirm = ref(false)
const cancelTargetOrder = ref(null)

const toggleOrder = (id) => {
  expandedOrder.value = expandedOrder.value === id ? null : id
}

const statusConfig = {
  pending: { label: 'Chờ xác nhận', colorClass: 'status-pending', icon: ClockIcon },
  shipping: { label: 'Đang giao hàng', colorClass: 'status-shipping', icon: TruckIcon },
  delivered: { label: 'Đã giao', colorClass: 'status-delivered', icon: CheckCircleIcon },
  cancelled: { label: 'Đã hủy', colorClass: 'status-cancelled', icon: XCircleIcon }
}

const activeFilter = ref('all')

const filteredOrders = computed(() => {
  if (activeFilter.value === 'all') return orders.value
  return orders.value.filter(o => o.status === activeFilter.value)
})

const formatPrice = (price) => new Intl.NumberFormat('vi-VN').format(price) + 'đ'

const openCancelConfirm = (order) => {
  cancelTargetOrder.value = order
  showCancelConfirm.value = true
}

const closeCancelConfirm = () => {
  showCancelConfirm.value = false
  cancelTargetOrder.value = null
}

const cancelOrder = async () => {
  if (!cancelTargetOrder.value) return
  const orderId = cancelTargetOrder.value.id
  cancellingOrderId.value = orderId
  try {
    await apiClient.put(`/Order/${orderId}/cancel`)
    const idx = orders.value.findIndex(o => o.id === orderId)
    if (idx !== -1) {
      orders.value[idx].status = 'cancelled'
    }
    closeCancelConfirm()
    toast.success('Đã hủy đơn hàng thành công!')
  } catch (e) {
    console.error('Lỗi khi hủy đơn hàng:', e)
    toast.error('Không thể hủy đơn hàng. Vui lòng liên hệ hỗ trợ!')
  } finally {
    cancellingOrderId.value = null
  }
}

onMounted(() => {
  fetchOrders()
  document.title = 'Lịch sử đơn hàng | FreshFarm'
})
</script>

<template>
  <div class="container" style="">
    <h1 class="page-title">Lịch sử đơn hàng</h1>
    <p class="page-subtitle">Theo dõi trạng thái và xem lại các đơn hàng đã đặt</p>

    <!-- Filters -->
    <div class="filter-tabs">
      <button
        v-for="filter in [
          { key: 'all', label: 'Tất cả' },
          { key: 'pending', label: 'Chờ xác nhận' },
          { key: 'shipping', label: 'Đang giao' },
          { key: 'delivered', label: 'Đã giao' },
          { key: 'cancelled', label: 'Đã hủy' }
        ]"
        :key="filter.key"
        @click="activeFilter = filter.key"
        :class="['filter-btn', activeFilter === filter.key ? 'active' : 'inactive']"
      >
        {{ filter.label }}
      </button>
    </div>

    <!-- Loading -->
    <div v-if="loadingOrders" class="state-container">
      <div class="state-icon loading-spin">⏳</div>
      <p class="state-text">Đang tải đơn hàng...</p>
    </div>

    <!-- Empty -->
    <div v-else-if="filteredOrders.length === 0" class="state-container">
      <div class="state-icon">📦</div>
      <p class="state-title">Không có đơn hàng nào</p>
      <p class="state-text">Hãy bắt đầu mua sắm nhé!</p>
      <button @click="$emit('navigate', 'products')" class="btn-primary">
        Mua sắm ngay
      </button>
    </div>

    <!-- Orders List -->
    <div v-else class="orders-list">
      <div
        v-for="order in filteredOrders"
        :key="order.id"
        class="order-card"
      >
        <!-- Order Header -->
        <button
          @click="toggleOrder(order.id)"
          class="order-header"
        >
          <div class="order-header-left">
            <div>
              <p class="order-code">{{ order.orderCode ? order.orderCode : '#' + order.id }}</p>
              <p class="order-date">{{ order.date }}</p>
            </div>
          </div>
          <div class="order-header-right">
            <span :class="['status-badge', statusConfig[order.status].colorClass]">
              <component :is="statusConfig[order.status].icon" class="icon-sm" />
              {{ statusConfig[order.status].label }}
            </span>
            <span class="order-total-sm">
              {{ formatPrice(order.total >= (order.items.reduce((acc, i) => acc + (i.price * i.qty), 0) + order.shipmentPrice) ? order.total : (order.items.reduce((acc, i) => acc + (i.price * i.qty), 0) + order.shipmentPrice)) }}
            </span>
            <ChevronDownIcon
              class="icon-sm icon-chevron"
              :class="{ 'rotated': expandedOrder === order.id }"
            />
          </div>
        </button>

        <!-- Order Detail (expanded) -->
        <div v-if="expandedOrder === order.id" class="order-detail">
          <div class="order-items">
            <div
              v-for="(item, idx) in order.items"
              :key="idx"
              class="order-item"
            >
              <div class="item-image-wrapper">
                <img :src="item.image" :alt="item.name" class="item-image" />
              </div>
              <div class="item-info">
                <p class="item-name">{{ item.name }}</p>
                <p class="item-qty">x{{ item.qty }}</p>
              </div>
              <span class="item-price">{{ formatPrice(item.price * item.qty) }}</span>
            </div>
          </div>

          <div class="order-summary-breakdown" style="margin-top: 1rem; border-top: 1px solid #f3f4f6; padding-top: 0.75rem;">
            <div class="d-flex justify-content-between align-items-center mb-1" style="font-size: 0.75rem; color: #6b7280;">
              <span>Tạm tính ({{ order.items.reduce((acc, i) => acc + i.qty, 0) }} sản phẩm)</span>
              <span>{{ formatPrice(order.items.reduce((acc, i) => acc + (i.price * i.qty), 0)) }}</span>
            </div>
            <div class="d-flex justify-content-between align-items-center mb-2" style="font-size: 0.75rem; color: #6b7280;">
              <span>Phí giao hàng</span>
              <span>{{ formatPrice(order.shipmentPrice) }}</span>
            </div>
            <div style="margin-top: 0.5rem; padding-top: 0.5rem; border-top: 1px dashed #e5e7eb; display: flex; align-items: center; justify-content: space-between;">
              <span style="font-size: 0.75rem; font-weight: 700; color: #374151;">Tổng thanh toán</span>
              <span style="font-size: 1rem; font-weight: 800; color: #059669;">
                {{ formatPrice(order.total >= (order.items.reduce((acc, i) => acc + (i.price * i.qty), 0) + order.shipmentPrice) ? order.total : (order.items.reduce((acc, i) => acc + (i.price * i.qty), 0) + order.shipmentPrice)) }}
              </span>
            </div>
          </div>

          <div class="order-actions">
            <div>
              <button
                v-if="order.status === 'pending'"
                @click.stop="openCancelConfirm(order)"
                :disabled="cancellingOrderId === order.id"
                class="btn-cancel-order"
              >
                <XCircleIcon class="icon-sm" />
                {{ cancellingOrderId === order.id ? 'Đang hủy...' : 'Hủy đơn hàng' }}
              </button>
            </div>
            <div>
              <button v-if="order.status === 'delivered'" class="btn-reorder">
                Đặt lại đơn này
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Cancel Confirmation Modal -->
    <Teleport to="body">
      <Transition name="fade">
        <div v-if="showCancelConfirm" class="modal-overlay" @click="closeCancelConfirm">
          <Transition name="zoom">
            <div v-if="showCancelConfirm" class="modal-content" @click.stop>
              <div class="modal-icon-wrapper">
                <ExclamationTriangleIcon class="icon-lg text-red" />
              </div>
              <h3 class="modal-title">Xác nhận hủy đơn?</h3>
              <p class="modal-desc">
                Bạn có chắc muốn hủy đơn hàng
                <span class="modal-bold-text">{{ cancelTargetOrder?.orderCode ? cancelTargetOrder.orderCode : '#' + cancelTargetOrder?.id }}</span>?
                Hành động này không thể hoàn tác.
              </p>
              <div class="modal-actions">
                <button
                  @click="closeCancelConfirm"
                  class="btn-modal-cancel"
                >
                  Không, giữ lại
                </button>
                <button
                  @click="cancelOrder"
                  :disabled="cancellingOrderId !== null"
                  class="btn-modal-confirm"
                >
                  {{ cancellingOrderId !== null ? 'Đang hủy...' : 'Hủy đơn hàng' }}
                </button>
              </div>
            </div>
          </Transition>
        </div>
      </Transition>
    </Teleport>


  </div>
</template>

<style scoped>
/* Base layout */
.container {
  max-width: 64rem;
  margin: 0 auto;
  padding: 2rem 1rem;
}
@media (min-width: 640px) {
  .container {
    padding-left: 1.5rem;
    padding-right: 1.5rem;
  }
}
@media (min-width: 1024px) {
  .container {
    padding-left: 2rem;
    padding-right: 2rem;
  }
}

.page-title {
  font-size: 1.5rem;
  font-weight: 800;
  color: #111827;
  margin-bottom: 0.25rem;
}

.page-subtitle {
  font-size: 0.875rem;
  color: #6b7280;
  margin-bottom: 1.5rem;
}

/* Filters */
.filter-tabs {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  overflow-x: auto;
  padding-bottom: 0.25rem;
}

.filter-btn {
  padding: 0.375rem 1rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 600;
  transition: all 0.2s;
  white-space: nowrap;
  border: none;
  cursor: pointer;
}

.filter-btn.active {
  background-color: #10b981;
  color: #ffffff;
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
}

.filter-btn.inactive {
  background-color: #f3f4f6;
  color: #4b5563;
}

.filter-btn.inactive:hover {
  background-color: #e5e7eb;
}

/* States (Loading & Empty) */
.state-container {
  text-align: center;
  padding: 4rem 0;
  background-color: #ffffff;
  border-radius: 0.75rem;
  border: 1px solid #f3f4f6;
}

.state-icon {
  font-size: 2.25rem;
  margin-bottom: 0.5rem;
}

.loading-spin {
  animation: spin 1s linear infinite;
  display: inline-block;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.state-title {
  font-size: 0.875rem;
  font-weight: 600;
  color: #374151;
  margin-bottom: 0;
}

.state-text {
  font-size: 0.75rem;
  color: #9ca3af;
  margin-top: 0.25rem;
  margin-bottom: 0;
}

.btn-primary {
  margin-top: 1rem;
  padding: 0.5rem 1.25rem;
  background-color: #10b981;
  color: #ffffff;
  font-size: 0.875rem;
  font-weight: 500;
  border-radius: 9999px;
  border: none;
  cursor: pointer;
  transition: background-color 0.2s;
}

.btn-primary:hover {
  background-color: #059669;
}

/* Orders List */
.orders-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.order-card {
  background-color: #ffffff;
  border-radius: 0.75rem;
  border: 1px solid #f3f4f6;
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  overflow: hidden;
  transition: box-shadow 0.2s;
}

.order-card:hover {
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

.order-header {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem 1.25rem;
  text-align: left;
  background: none;
  border: none;
  cursor: pointer;
}

.order-header-left {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.order-code {
  font-size: 0.875rem;
  font-weight: 700;
  color: #1f2937;
  margin: 0;
}

.order-date {
  font-size: 0.625rem;
  color: #9ca3af;
  margin: 0.125rem 0 0 0;
}

.order-header-right {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.status-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
  padding: 0.125rem 0.625rem;
  border-radius: 9999px;
  font-size: 0.625rem;
  font-weight: 700;
}

.status-pending { background-color: #fef3c7; color: #b45309; }
.status-shipping { background-color: #dbeafe; color: #1d4ed8; }
.status-delivered { background-color: #d1fae5; color: #047857; }
.status-cancelled { background-color: #fee2e2; color: #b91c1c; }

.order-total-sm {
  font-size: 0.875rem;
  font-weight: 800;
  color: #1f2937;
  display: block;
}

.icon-sm {
  width: 0.75rem;
  height: 0.75rem;
}

.icon-chevron {
  width: 1rem;
  height: 1rem;
  color: #9ca3af;
  transition: transform 0.2s;
}

.icon-chevron.rotated {
  transform: rotate(180deg);
}

/* Order Detail */
.order-detail {
  border-top: 1px solid #f3f4f6;
  padding: 1rem 1.25rem;
  background-color: rgba(249, 250, 251, 0.5);
}

.order-items {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.order-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.item-image-wrapper {
  width: 3rem;
  height: 3rem;
  border-radius: 0.5rem;
  overflow: hidden;
  border: 1px solid #f3f4f6;
  flex-shrink: 0;
}

.item-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.item-info {
  flex: 1;
  min-width: 0;
}

.item-name {
  font-size: 0.875rem;
  font-weight: 600;
  color: #1f2937;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  margin: 0;
}

.item-qty {
  font-size: 0.75rem;
  color: #9ca3af;
  margin: 0;
}

.item-price {
  font-size: 0.875rem;
  font-weight: 700;
  color: #374151;
}

.order-summary {
  margin-top: 1rem;
  padding-top: 0.75rem;
  border-top: 1px solid #e5e7eb;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.summary-label {
  font-size: 0.75rem;
  color: #9ca3af;
}

.summary-value {
  font-size: 1rem;
  font-weight: 800;
  color: #059669;
}

.order-actions {
  margin-top: 0.75rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.btn-cancel-order {
  padding: 0.375rem 1rem;
  font-size: 0.75rem;
  font-weight: 600;
  color: #dc2626;
  border: 1px solid #fecaca;
  border-radius: 9999px;
  background: none;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 0.375rem;
  transition: background-color 0.2s;
}

.btn-cancel-order:hover:not(:disabled) {
  background-color: #fef2f2;
}

.btn-cancel-order:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-reorder {
  padding: 0.375rem 1rem;
  font-size: 0.75rem;
  font-weight: 600;
  color: #059669;
  border: 1px solid #a7f3d0;
  border-radius: 9999px;
  background: none;
  cursor: pointer;
  transition: background-color 0.2s;
}

.btn-reorder:hover {
  background-color: #ebf2ee;
}

/* Modal */
.modal-overlay {
  position: fixed;
  inset: 0;
  z-index: 50;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
  background-color: rgba(17, 24, 39, 0.4);
  backdrop-filter: blur(4px);
}

.modal-content {
  position: relative;
  background-color: #ffffff;
  border-radius: 1rem;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  width: 100%;
  max-width: 24rem;
  padding: 1.5rem;
  text-align: center;
}

.modal-icon-wrapper {
  margin: 0 auto 1rem auto;
  width: 3.5rem;
  height: 3.5rem;
  border-radius: 9999px;
  background-color: #fee2e2;
  display: flex;
  align-items: center;
  justify-content: center;
}

.icon-lg {
  width: 1.75rem;
  height: 1.75rem;
}

.text-red {
  color: #ef4444;
}

.modal-title {
  font-size: 1.125rem;
  font-weight: 700;
  color: #1f2937;
  margin-bottom: 0.25rem;
}

.modal-desc {
  font-size: 0.875rem;
  color: #6b7280;
  margin-bottom: 1.5rem;
}

.modal-bold-text {
  font-weight: 700;
  color: #374151;
}

.modal-actions {
  display: flex;
  gap: 0.75rem;
}

.btn-modal-cancel {
  flex: 1;
  padding: 0.625rem 1rem;
  font-size: 0.875rem;
  font-weight: 600;
  color: #374151;
  background-color: #f3f4f6;
  border: none;
  border-radius: 0.75rem;
  cursor: pointer;
  transition: background-color 0.2s;
}

.btn-modal-cancel:hover {
  background-color: #e5e7eb;
}

.btn-modal-confirm {
  flex: 1;
  padding: 0.625rem 1rem;
  font-size: 0.875rem;
  font-weight: 600;
  color: #ffffff;
  background-color: #ef4444;
  border: none;
  border-radius: 0.75rem;
  cursor: pointer;
  transition: background-color 0.2s;
}

.btn-modal-confirm:hover:not(:disabled) {
  background-color: #dc2626;
}

.btn-modal-confirm:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Transitions */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease-out;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.zoom-enter-active,
.zoom-leave-active {
  transition: all 0.2s ease-out;
}

.zoom-enter-from,
.zoom-leave-to {
  opacity: 0;
  transform: scale(0.95);
}
</style>
