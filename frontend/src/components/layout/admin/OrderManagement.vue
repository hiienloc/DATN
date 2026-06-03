<template>
  <div class="p-4 min-vh-100" style="background: var(--ff-bg-admin); ">

    <!-- Header -->
    <div class="d-flex align-items-center justify-content-between mb-4">
      <div>
        <h1 class="fs-5 fw-bold text-dark mb-0">Quản lý đơn hàng</h1>
        <p class="small text-muted mt-1 mb-0">Tổng cộng {{ filteredOrders.length }} đơn hàng</p>
      </div>
    </div>

    <!-- Search & Filter -->
    <div class="bg-white p-3 rounded-2 shadow-sm border mb-4">
      <div class="d-flex flex-wrap align-items-center gap-3">
        <select
          v-model="filterStatus"
          class="form-select rounded-2 small"
          style="max-width: 240px;"
        >
          <option value="">Tất cả trạng thái</option>
          <option value="pending">Chờ xác nhận</option>
          <option value="confirmed">Đã xác nhận</option>
          <option value="shipping">Đang giao hàng</option>
          <option value="completed">Hoàn thành</option>
          <option value="cancelled">Đã hủy</option>
        </select>
      </div>
    </div>

    <!-- Table -->
    <div class="bg-white rounded-2 border shadow-sm overflow-hidden">
      <table class="table table-hover ff-table mb-0" style="font-size: 0.9rem;">
        <thead>
          <tr class="border-bottom text-uppercase" style="background: #fafafa;">
            <th class="px-3 py-2 text-muted fw-bold small text-center" style="width:50px;">STT</th>
            <th class="px-3 py-2 text-muted fw-bold small" style="width:130px;">Mã đơn hàng</th>
            <th class="px-3 py-2 text-muted fw-bold small">Khách hàng</th>
            <th class="px-3 py-2 text-muted fw-bold small">Ngày đặt</th>
            <th class="px-3 py-2 text-muted fw-bold small text-end">Tổng tiền</th>
            <th class="px-3 py-2 text-muted fw-bold small">Thanh toán</th>
            <th class="px-3 py-2 text-muted fw-bold small" style="width:140px;">Trạng thái</th>
            <th class="px-3 py-2 text-muted fw-bold small text-center" style="width:70px;">Xem</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="loading">
            <td colspan="7" class="text-center py-5 text-muted">
               <div class="spinner-border spinner-border-sm text-success me-2"></div>
               Đang tải dữ liệu đơn hàng...
            </td>
          </tr>
          <tr v-else-if="filteredOrders.length === 0">
            <td colspan="7" class="text-center py-5 text-muted">Không có đơn hàng nào</td>
          </tr>
          <tr v-for="(order, index) in paginatedOrders" :key="order.id" class="align-middle border-bottom hover-bg">
            <td class="px-3 py-2 text-center text-muted small fw-medium">{{ (currentPage - 1) * itemsPerPage + index + 1 }}</td>
            <td class="px-3 py-2">
              <span class="fw-bold text-dark font-mono bg-secondary bg-opacity-10 px-2 py-1 rounded border small">{{ order.orderCode || '#' + order.id }}</span>
            </td>
            <td class="px-3 py-2">
              <div class="fw-bold text-dark small">{{ order.customerName }}</div>
              <div class="text-muted" style="font-size: 0.75rem;">{{ order.phone }}</div>
            </td>
            <td class="px-3 py-2 text-muted" style="font-size: 0.8rem;">{{ order.date }}</td>
            <td class="px-3 py-2 text-end fw-bold text-dark small">{{ formatPrice(order.total) }}</td>
            <td class="px-3 py-2">
              <div class="d-flex flex-column gap-1">
                <span class="badge rounded-1 px-2 py-1 fw-bold text-uppercase" style="font-size:0.6rem;background:#475569;color:#fff;width:fit-content;">
                  {{ order.paymentMethod || 'COD' }}
                </span>
                <span
                  class="badge rounded-1 px-2 py-1 fw-bold text-uppercase"
                  style="font-size:0.6rem;width:fit-content;"
                  :style="getPaymentStatusStyle(order.paymentStatus, order.status)"
                >
                  {{ getPaymentStatusLabel(order.paymentStatus, order.status) }}
                </span>
              </div>
            </td>
            <td class="px-3 py-2">
              <span
                class="badge rounded-pill px-2 py-1 fw-bold d-inline-flex align-items-center gap-1 text-uppercase"
                style="font-size: 0.65rem;"
                :style="getStatusStyle(order.status)"
              >
                <ExclamationCircleIcon v-if="order.status === 'pending'" style="width:12px;height:12px;" />
                <CheckCircleIcon v-if="order.status === 'confirmed'" style="width:12px;height:12px;" />
                <TruckIcon v-if="order.status === 'shipping'" style="width:12px;height:12px;" />
                <CheckCircleIcon v-if="order.status === 'completed'" style="width:12px;height:12px;" />
                <MinusCircleIcon v-if="order.status === 'cancelled'" style="width:12px;height:12px;" />
                {{ getStatusLabel(order.status) }}
              </span>
            </td>
            <td class="px-3 py-2 text-center">
                <button @click="openView(order)" class="btn btn-sm btn-outline-success border rounded-2 p-1">
                  <InformationCircleIcon style="width:16px;height:16px;" />
                </button>
            </td>
          </tr>
        </tbody>
      </table>

      <!-- Pagination Footer (Bootstrap 5) -->
      <div v-if="totalPages > 1" class="d-flex flex-column flex-md-row align-items-center justify-content-between bg-white p-3 border-top border-light gap-3">
        <div class="small text-muted">
          Hiển thị <b>{{ (currentPage - 1) * itemsPerPage + 1 }}</b> - <b>{{ Math.min(currentPage * itemsPerPage, filteredOrders.length) }}</b> trên tổng số <b>{{ filteredOrders.length }}</b> đơn hàng
        </div>
        <nav>
          <ul class="pagination pagination-sm mb-0 gap-1">
            <!-- Nút Trước -->
            <li class="page-item" :class="{ disabled: currentPage === 1 }">
              <button class="page-link border-0 rounded-2 px-3 bg-light text-dark d-flex align-items-center gap-1" 
                      @click="currentPage > 1 ? currentPage-- : null">
                <ChevronLeftIcon style="width: 14px; height: 14px;" /> Trước
              </button>
            </li>
            
            <!-- Số trang -->
            <li v-for="page in totalPages" :key="page" class="page-item" :class="{ active: currentPage === page }">
              <button class="page-link border-0 rounded-2 px-3 fw-semibold transition-all"
                      :style="currentPage === page 
                        ? 'background-color: #4e7c66; color: white; transform: scale(1.05);' 
                        : 'background-color: #f8f9fa; color: #495057;'"
                      @click="currentPage = page">
                {{ page }}
              </button>
            </li>

            <!-- Nút Sau -->
            <li class="page-item" :class="{ disabled: currentPage === totalPages }">
              <button class="page-link border-0 rounded-2 px-3 bg-light text-dark d-flex align-items-center gap-1" 
                      @click="currentPage < totalPages ? currentPage++ : null">
                Sau <ChevronRightIcon style="width: 14px; height: 14px;" />
              </button>
            </li>
          </ul>
        </nav>
      </div>
    </div>

    <!-- Modal Xem Chi Tiết Đơn Hàng -->
    <Teleport to="body">
      <div v-if="showModal" class="ff-modal-container">
        <div class="ff-modal-backdrop" @click="closeModal" />
        <div class="ff-modal-content" style="max-width: 800px; max-height: 90vh; display: flex; flex-direction: column;" @click.stop>
          <!-- Header -->
          <div class="p-4 border-bottom bg-light d-flex justify-content-between align-items-center">
            <div>
               <h2 class="fw-bold fs-5 mb-1 text-dark">Chi tiết đơn hàng</h2>
               <div class="d-flex align-items-center gap-2">
                 <span class="fw-bold text-success fs-5">{{ viewOrder?.orderCode || '#' + viewOrder?.id }}</span>
                 <span class="small text-muted d-flex align-items-center gap-1">
                   <CalendarIcon style="width:14px;height:14px;" />
                   {{ viewOrder?.date }}
                 </span>
               </div>
            </div>
            <button @click="closeModal" class="btn btn-sm btn-light rounded-circle border">
              <XMarkIcon style="width:20px;height:20px;" class="text-muted" />
            </button>
          </div>

          <!-- Body -->
          <div class="p-4 overflow-auto flex-grow-1" style="background: #fdfdfd;">
            <div class="row g-4">
              <!-- Cột trái: Thông tin chung -->
              <div class="col-md-5">
                <div class="d-flex flex-column gap-4">
                  <!-- Trạng thái -->
                  <div class="p-4 rounded-2 border bg-white shadow-sm">
                    <label class="form-label small fw-bold text-muted mb-3 d-flex align-items-center gap-2">
                      <TruckIcon style="width:16px;height:16px;" />
                      TRẠNG THÁI ĐƠN HÀNG
                    </label>
                    <select
                      v-model="editStatus"
                      class="form-select fw-bold rounded-2 border-2"
                      :style="getStatusStyle(editStatus)"
                      @change="updateOrderStatus"
                      :disabled="viewOrder?.status === 'completed' || viewOrder?.status === 'cancelled'"
                    >
                      <option value="pending">Chờ xác nhận</option>
                      <option value="confirmed">Đã xác nhận</option>
                      <option value="shipping">Đang giao hàng</option>
                      <option value="completed">Hoàn thành</option>
                      <option value="cancelled">Đã hủy</option>
                    </select>
                    <p v-if="viewOrder?.status === 'completed' || viewOrder?.status === 'cancelled'" class="small text-danger mt-3 mb-0 fw-semibold">
                      Đơn hàng đã hoàn thành hoặc đã hủy, không thể chỉnh sửa trạng thái nữa.
                    </p>
                    <p v-else class="small text-muted mt-3 mb-0">Cập nhật trạng thái để khách hàng nhận được thông báo.</p>
                  </div>

                  <!-- Thông tin khách hàng & Giao hàng -->
                  <div class="p-4 rounded-2 border bg-white shadow-sm">
                    <label class="form-label small fw-bold text-muted mb-3 d-flex align-items-center gap-2">
                      <UserIcon style="width:16px;height:16px;" />
                      THÔNG TIN GIAO NHẬN
                    </label>
                    <div class="d-flex flex-column gap-3">
                      <div>
                        <div class="fw-bold text-dark">{{ viewOrder?.customerName }}</div>
                        <div class="text-muted small">{{ viewOrder?.phone }}</div>
                      </div>
                      <div class="pt-3 border-top d-flex gap-2">
                        <MapPinIcon style="width:18px;height:18px;" class="text-danger shrink-0 mt-1" />
                        <div class="small text-dark fw-medium leading-relaxed">
                          {{ viewOrder?.address || 'Không có thông tin địa chỉ' }}
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- Thanh toán -->
                  <div class="p-4 rounded-2 border bg-white shadow-sm">
                    <label class="form-label small fw-bold text-muted mb-3 d-flex align-items-center gap-2">
                      <CreditCardIcon style="width:16px;height:16px;" />
                      THANH TOÁN
                    </label>
                    <div class="d-flex justify-content-between align-items-center mb-2">
                      <span class="small text-muted">Phương thức:</span>
                      <span class="badge bg-primary bg-opacity-10 text-primary fw-bold text-uppercase">{{ viewOrder?.paymentMethod || 'COD' }}</span>
                    </div>
                    <div class="d-flex justify-content-between align-items-center">
                      <span class="small text-muted">Tình trạng:</span>
                      <span
                        class="badge fw-bold"
                        :style="getPaymentStatusStyle(viewOrder?.paymentStatus, viewOrder?.status)"
                      >
                        {{ getPaymentStatusLabel(viewOrder?.paymentStatus, viewOrder?.status) }}
                      </span>
                    </div>
                    <!-- Nút xác nhận thanh toán COD nếu là COD và chưa thanh toán -->
                    <div v-if="(viewOrder?.paymentMethod?.toUpperCase() === 'COD' || !viewOrder?.paymentMethod) && getPaymentStatusLabel(viewOrder?.paymentStatus, viewOrder?.status) !== 'Đã thanh toán' && viewOrder?.status !== 'cancelled'" class="mt-3 pt-3 border-top">
                      <button
                        @click="confirmCodPayment(viewOrder.id)"
                        class="btn btn-sm btn-success w-100 rounded-2 fw-bold py-2 shadow-sm"
                        :disabled="isConfirmingPayment"
                      >
                        <span v-if="isConfirmingPayment" class="spinner-border spinner-border-sm me-1"></span>
                        Xác nhận thanh toán COD
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Cột phải: Danh sách sản phẩm & Tổng tiền -->
              <div class="col-md-7">
                <div class="bg-white rounded-2 border shadow-sm overflow-hidden h-100 d-flex flex-column">
                  <div class="p-3 bg-light border-bottom fw-bold small text-muted d-flex align-items-center gap-2">
                    <ShoppingBagIcon style="width:16px;height:16px;" />
                    DANH SÁCH SẢN PHẨM
                  </div>
                  <div class="flex-grow-1 overflow-auto">
                    <div v-for="(item, idx) in viewOrder?.items" :key="idx" class="p-3 d-flex align-items-center gap-3 border-bottom">
                      <div class="rounded-2 border overflow-hidden shrink-0" style="width:64px;height:64px;">
                        <img v-if="item.image" :src="getImageUrl(item.image)" class="w-100 h-100 object-fit-cover" />
                        <div v-else class="w-100 h-100 bg-light d-flex align-items-center justify-content-center">
                          <ShoppingBagIcon style="width:24px;height:24px;" class="text-muted opacity-25" />
                        </div>
                      </div>
                      <div class="flex-grow-1">
                        <div class="fw-bold text-dark small mb-1">{{ item.name }}</div>
                        <div class="d-flex justify-content-between align-items-center mt-1">
                          <span class="small text-muted">{{ formatPrice(item.price) }} × {{ item.qty }}</span>
                          <span class="fw-bold text-dark small">{{ formatPrice(item.price * item.qty) }}</span>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="p-4 bg-light border-top mt-auto">
                    <div class="d-flex justify-content-between mb-2 small text-muted">
                      <span>Tạm tính:</span>
                      <span>{{ formatPrice(viewOrder?.items?.reduce((acc, i) => acc + (i.price * i.qty), 0) || 0) }}</span>
                    </div>
                    <div class="d-flex justify-content-between mb-3 small text-muted">
                      <span>Phí vận chuyển:</span>
                      <span>{{ formatPrice(viewOrder?.shipmentPrice || 0) }}</span>
                    </div>
                    <div class="d-flex justify-content-between align-items-center pt-3 border-top border-2 border-white">
                      <span class="fw-bold text-dark">TỔNG CỘNG:</span>
                      <span class="fw-bold fs-4 text-success">{{ formatPrice(viewOrder?.total || 0) }}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Footer -->
          <div class="p-3 border-top bg-white d-flex justify-content-end">
            <button @click="closeModal" class="btn btn-secondary px-4 rounded-2 fw-bold">Đóng</button>
          </div>
        </div>
      </div>
    </Teleport>

  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import apiClient from '@/api/axios'
import { toast } from '@/utils/toast'

const props = defineProps({
  searchQuery: { type: String, default: '' }
})
import {
  ExclamationCircleIcon,
  TruckIcon,
  CheckCircleIcon,
  MinusCircleIcon,
  InformationCircleIcon,
  XMarkIcon,
  ShoppingBagIcon,
  UserIcon,
  MapPinIcon,
  CreditCardIcon,
  CalendarIcon,
  ChevronLeftIcon,
  ChevronRightIcon
} from '@heroicons/vue/24/outline'

const getErrorMessage = (error) => {
  return error.response?.data?.message || error.response?.data?.title || error.message
}

// ── Helpers ────────────────────────────────────────────────────────────────
const removeAccents = (str) => {
  return str ? str.normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd').replace(/Đ/g, 'D') : ''
}

function formatPrice(value) {
  return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(value)
}

function getStatusLabel(status) {
  const labels = {
    pending: 'Chờ xác nhận',
    confirmed: 'Đã xác nhận',
    shipping: 'Đang giao hàng',
    completed: 'Hoàn thành',
    cancelled: 'Đã hủy'
  }
  return labels[status] || status
}

function getStatusStyle(status) {
  const styles = {
    pending: 'background:#fff8e1;color:#f59e0b;',
    confirmed: 'background:#e0f2fe;color:#0284c7;',
    shipping: 'background:#e0f2fe;color:#0284c7;',
    completed: 'background:#ebf2ee;color:#4e7c66;',
    cancelled: 'background:#fde8e8;color:#dc3545;'
  }
  return styles[status] || 'background:#f0f0f0;color:#555;'
}

function getPaymentStatusStyle(status, orderStatus) {
  // Nếu đơn hàng đã hoàn thành thì mặc định thanh toán cũng xong
  if (orderStatus === 'completed') return 'background:#ebf2ee;color:#4e7c66;'
  
  if (!status) return 'background:#fff7ed;color:#ea580c;'
  const s = String(status).toLowerCase()
  if (['paid', 'completed', 'thành công', 'đã thanh toán'].includes(s)) {
    return 'background:#ebf2ee;color:#4e7c66;'
  }
  if (['failed', 'cancelled', 'thất bại', 'đã hủy'].includes(s)) {
    return 'background:#fde8e8;color:#dc3545;'
  }
  return 'background:#fff7ed;color:#ea580c;'
}

function getPaymentStatusLabel(status, orderStatus) {
  if (orderStatus === 'completed') return 'Đã thanh toán'
  
  if (!status) return 'Chờ thanh toán'
  const s = String(status).toLowerCase()
  if (['paid', 'completed', 'thành công', 'đã thanh toán'].includes(s)) {
    return 'Đã thanh toán'
  }
  if (['failed', 'thất bại'].includes(s)) {
    return 'Thanh toán lỗi'
  }
  if (s === 'cancelled' || s === 'đã hủy') {
    return 'Đã hủy'
  }
  if (s === 'pending' || s === 'chờ thanh toán') {
    return 'Chờ thanh toán'
  }
  return status
}

const BASE_URL = import.meta.env.VITE_API_URL || window.location.origin

function getImageUrl(url) {
  if (!url) return ''
  if (url.startsWith('http')) return url
  return `${BASE_URL}${url.startsWith('/') ? '' : '/'}${url}`
}

// ── State ──────────────────────────────────────────────────────────────────
const filterStatus = ref('')
const currentPage = ref(1)
const itemsPerPage = ref(10)
const showModal = ref(false)
const viewOrder = ref(null)
const editStatus = ref('')
const loading = ref(false)
const orders = ref([])
const isConfirmingPayment = ref(false)

// Map backend status to frontend keys
const statusMap = {
  'Chờ xác nhận': 'pending',
  'Đã xác nhận': 'confirmed',
  'Confirmed': 'confirmed',
  'Đang giao hàng': 'shipping',
  'Hoàn thành': 'completed',
  'Đã hủy': 'cancelled'
}

const revStatusMap = {
  'pending': 'Chờ xác nhận',
  'confirmed': 'Đã xác nhận',
  'shipping': 'Đang giao hàng',
  'completed': 'Hoàn thành',
  'cancelled': 'Đã hủy'
}

const fetchOrders = async () => {
  loading.value = true
  try {
    const response = await apiClient.get('/Order')
    const data = response.data.data || response.data || []
    orders.value = data.map(o => ({
      id: o.orderId,
      orderCode: o.orderCode,
      customerName: o.receiveName,
      phone: o.receivePhone,
      address: o.receiveAddress,
      shipmentPrice: o.shipmentPrice,
      date: new Date(o.orderDate).toLocaleString('vi-VN'),
      status: statusMap[o.orderStatus] || o.orderStatus,
      total: o.totalAmount,
      paymentMethod: o.payment?.paymentMethod,
      paymentStatus: o.payment?.paymentStatus,
      email: o.email, // Lấy email từ backend
      items: (o.orderItems || []).map(i => ({
        name: i.packageName,
        price: i.unitPrice,
        qty: i.quantity,
        image: i.imageUrl
      }))
    }))
  } catch (error) {
    console.error('Lỗi khi tải danh sách đơn hàng:', error)
  } finally {
    loading.value = false
  }
}

onMounted(fetchOrders)

// ── Computed ───────────────────────────────────────────────────────────────
const filteredOrders = computed(() =>
  orders.value.filter(o => {
    const matchStatus = !filterStatus.value || o.status === filterStatus.value
    
    const query = removeAccents(props.searchQuery).toLowerCase().trim()
    if (!query) return matchStatus
    
    const codeMatch = o.orderCode ? removeAccents(o.orderCode).toLowerCase().includes(query) : false
    const nameMatch = o.customerName ? removeAccents(o.customerName).toLowerCase().includes(query) : false
    const phoneMatch = o.phone ? removeAccents(o.phone).toLowerCase().includes(query) : false
    const emailMatch = o.email ? removeAccents(o.email).toLowerCase().includes(query) : false
    const idMatch = o.id ? String(o.id).includes(query) : false
    
    return matchStatus && (codeMatch || nameMatch || phoneMatch || emailMatch || idMatch)
  })
)

const totalPages = computed(() => Math.ceil(filteredOrders.value.length / itemsPerPage.value))

const paginatedOrders = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  return filteredOrders.value.slice(start, start + itemsPerPage.value)
})

watch([filterStatus, () => props.searchQuery], () => {
  currentPage.value = 1
})

// ── Methods ────────────────────────────────────────────────────────────────
function openView(order) {
  viewOrder.value = { ...order }
  editStatus.value = order.status
  showModal.value = true
}

function closeModal() {
  showModal.value = false
  viewOrder.value = null
}

async function confirmCodPayment(orderId) {
  if (isConfirmingPayment.value) return
  isConfirmingPayment.value = true
  try {
    const response = await apiClient.put(`/Payment/cod-confirm/${orderId}`)
    
    // Cập nhật trạng thái cục bộ
    const idx = orders.value.findIndex(o => o.id === orderId)
    if (idx !== -1) {
      orders.value[idx].paymentStatus = 'Đã thanh toán'
      if (viewOrder.value && viewOrder.value.id === orderId) {
        viewOrder.value.paymentStatus = 'Đã thanh toán'
      }
    }
    toast.success(response.data?.message || 'Xác nhận thanh toán COD thành công!')
  } catch (error) {
    console.error('Lỗi khi xác nhận thanh toán COD:', error)
    toast.error(getErrorMessage(error) || 'Không thể xác nhận thanh toán COD!')
  } finally {
    isConfirmingPayment.value = false
  }
}

async function updateOrderStatus() {
  if (!viewOrder.value) return
  if (viewOrder.value.status === 'completed' || viewOrder.value.status === 'cancelled') {
    toast.error('Đơn hàng đã hoàn thành hoặc đã hủy, không thể thay đổi trạng thái!')
    return
  }
  
  try {
    const backendStatus = revStatusMap[editStatus.value] || editStatus.value
    await apiClient.put(`/Order/${viewOrder.value.id}/status`, backendStatus, {
      headers: { 'Content-Type': 'application/json' }
    })
    
    const idx = orders.value.findIndex(o => o.id === viewOrder.value.id)
    if (idx !== -1) {
      orders.value[idx].status = editStatus.value
      viewOrder.value.status = editStatus.value
      
      // Nếu trạng thái đơn đổi thành Hoàn thành (completed), tự động cập nhật hiển thị thanh toán thành Đã thanh toán
      if (editStatus.value === 'completed') {
        orders.value[idx].paymentStatus = 'Đã thanh toán'
        viewOrder.value.paymentStatus = 'Đã thanh toán'
      }
    }
    toast.success('Cập nhật trạng thái đơn hàng thành công!')
  } catch (error) {
    console.error('Lỗi khi cập nhật trạng thái đơn hàng:', error)
    toast.error('Không thể cập nhật trạng thái đơn hàng!')
    editStatus.value = viewOrder.value.status
  }
}
</script>

<style scoped>
.ff-modal-container {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 2000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
}

.ff-modal-backdrop {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(15, 23, 42, 0.4);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
}

.ff-modal-content {
  position: relative;
  width: 100%;
  background: white;
  border-radius: 0.5rem;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  z-index: 10;
  overflow: hidden;
  animation: modalSlideUp 0.3s ease-out;
}

.hover-bg:hover {
  background-color: #f8fafc !important;
}

@keyframes modalSlideUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

.transition-all {
  transition: all 0.2s ease;
}

.font-mono {
  
}
</style>
