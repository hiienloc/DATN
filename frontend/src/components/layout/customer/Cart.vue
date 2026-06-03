<script setup>
import { ref, computed, onMounted } from 'vue'
import { TrashIcon, TruckIcon } from '@heroicons/vue/24/outline'
import { useCart } from '@/composables/useCart'
import apiClient from '@/api/axios'
import { toast } from '@/utils/toast'
import vnpayLogo from '@/assets/vnpay-logo.png'


const SHIPPING_FEE = 25000

const emit = defineEmits(['navigate'])

const {
  cartItems,
  isLoadingCart,
  fetchCart,
  cartSubtotal: subtotal,
  cartCount: itemCount,
  increaseQty,
  decreaseQty,
  removeFromCart,
  clearCart
} = useCart()

const total = computed(() => subtotal.value + SHIPPING_FEE)

onMounted(() => { fetchCart() })

const formatPrice = (price) => new Intl.NumberFormat('vi-VN').format(price) + 'đ'

// ── Checkout state ────────────────────────────────────────────────────────
const showCheckoutModal = ref(false)
const orderForm = ref({ fullName: '', phone: '', address: '', paymentMethod: 'COD' })
const isProcessing = ref(false)

// ── Delete confirmation state ──────────────────────────────────────────────
const showDeleteConfirm = ref(false)
const itemToDelete = ref(null)

const confirmDelete = (item) => {
  itemToDelete.value = item
  showDeleteConfirm.value = true
}

const executeDelete = async () => {
  if (itemToDelete.value) {
    await removeFromCart(itemToDelete.value.cartItemId)
    showDeleteConfirm.value = false
    itemToDelete.value = null
  }
}

// ✅ FIX: Tách decode JWT ra util — dùng chung thay vì viết lại
const getUserIdFromToken = () => {
  const token = localStorage.getItem('token')
  if (!token) return null
  try {
    const base64Url = token.split('.')[1]
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/')
    const jsonPayload = decodeURIComponent(
      atob(base64).split('').map(c => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2)).join('')
    )
    const payload = JSON.parse(jsonPayload)
    return (
      payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ||
      payload['nameid'] ||
      payload['id'] ||
      payload['sub']
    )
  } catch {
    return null
  }
}

// ✅ FIX: Reset form mỗi lần mở modal — tránh dữ liệu cũ còn lại
const openCheckout = () => {
  if (cartItems.value.length === 0) {
    toast.warning('Giỏ hàng của bạn hiện đang trống!')
    return
  }

  const token = localStorage.getItem('token')
  const role = localStorage.getItem('role') || ''

  if (!token) {
    toast.info('Vui lòng đăng nhập tài khoản Khách hàng để tiến hành đặt hàng!')
    emit('navigate', 'login')
    return
  }

  if (role.toLowerCase() === 'admin') {
    toast.warning('Tài khoản Admin không thể mua hàng. Vui lòng dùng tài khoản Khách hàng!')
    return
  }

  // Reset form trước khi mở
  orderForm.value = { fullName: '', phone: '', address: '', paymentMethod: 'COD' }
  showCheckoutModal.value = true
}

const submitOrder = async () => {
  const fullName = orderForm.value.fullName ? orderForm.value.fullName.trim() : ''
  const phone = orderForm.value.phone ? orderForm.value.phone.trim() : ''
  const address = orderForm.value.address ? orderForm.value.address.trim() : ''

  // Validate thông tin giao hàng trống
  if (!fullName || !phone || !address) {
    toast.warning('Vui lòng điền đầy đủ thông tin giao hàng!')
    return
  }

  // Validate độ dài họ tên (3 - 50 ký tự) khớp với backend
  if (fullName.length < 3 || fullName.length > 50) {
    toast.error('Họ tên người nhận phải từ 3 đến 50 ký tự.')
    return
  }

  // Validate SĐT đủ 10 số và bắt đầu bằng số 0 khớp với backend
  if (!/^0\d{9}$/.test(phone)) {
    toast.error('Số điện thoại phải có đúng 10 chữ số và bắt đầu bằng số 0.')
    return
  }

  // Validate độ dài địa chỉ (10 - 255 ký tự) khớp với backend
  if (address.length < 10 || address.length > 255) {
    toast.error('Địa chỉ nhận hàng phải từ 10 đến 255 ký tự.')
    return
  }

  isProcessing.value = true

  try {
    const rawId = getUserIdFromToken()
    const userId = rawId ? Number(rawId) : null

    if (!userId) {
      toast.error('Phiên làm việc đã hết hạn. Vui lòng đăng nhập lại!')
      emit('navigate', 'login')
      return
    }

    const paymentMethod = orderForm.value.paymentMethod === 'VNPAY'
      ? 'VNPay'
      : orderForm.value.paymentMethod

    const orderData = {
      userId,
      receiveName: fullName,
      receivePhone: phone,
      receiveAddress: address,
      paymentMethod,
      shipmentPrice: SHIPPING_FEE,
      orderItems: cartItems.value.map(item => ({
        packageId: item.packageId,
        quantity: item.quantity
      }))
    }

    const response = await apiClient.post('/Payment/create-payment', orderData)

    // ✅ FIX: Gộp check URL — tránh lặp code
    const redirectUrl = response.data?.url || response.data?.data?.url

    // ✅ FIX: Chỉ xóa giỏ sau khi biết chắc kết quả
    if (redirectUrl) {
      // VNPay → xóa giỏ rồi redirect
      await clearCart()
      window.location.href = redirectUrl
    } else {
     
      await clearCart()
      showCheckoutModal.value = false
      toast.success(response.data?.message || 'Đặt hàng thành công! Cảm ơn bạn đã tin tưởng FreshFarm.')
      emit('navigate', 'home')
    }
  } catch (error) {
    // ✅ Không xóa giỏ khi có lỗi — giữ lại để user thử lại
    let msg = 'Có lỗi xảy ra khi xử lý đơn hàng.'
    if (error.response?.data) {
      const data = error.response.data
      if (data.errors) msg = Object.values(data.errors).flat().join(' ')
      else if (data.message) msg = data.message
      else if (typeof data === 'string') msg = data
    } else {
      msg = error.message
    }
    toast.error('Lỗi đặt hàng: ' + msg)
  } finally {
    isProcessing.value = false
  }
}
</script>

<template>
  <div class="min-vh-100" style="background:#f8faf5; ">
    <div class="container-xl px-3 px-sm-4 py-4">

      <!-- Header -->
      <div class="mb-4">
        <h1 class="fs-5 fw-extrabold text-dark mb-1">Giỏ hàng của bạn</h1>
        <p class="small text-muted mb-0">
          Bạn đang có
          <span class="fw-semibold text-success">{{ itemCount }} sản phẩm</span>
          trong giỏ hàng
        </p>
      </div>

      <!-- Loading -->
      <div v-if="isLoadingCart" class="text-center py-5">
        <div class="spinner-border text-success" role="status"></div>
        <p class="text-muted small mt-2">Đang tải giỏ hàng...</p>
      </div>

      <!-- Empty Cart -->
      <div
        v-else-if="cartItems.length === 0"
        class="text-center py-5 bg-white rounded-2xl border shadow-sm"
        style="border-color:#f3f4f6;"
      >
        <div style="font-size:3rem;" class="mb-2">🛒</div>
        <h2 class="fw-bold text-muted small mb-1">Giỏ hàng trống</h2>
        <p class="text-muted" style="font-size:0.8rem;">Hãy thêm sản phẩm yêu thích vào giỏ hàng nhé!</p>
        <button
          @click="$emit('navigate', 'products')"
          class="btn btn-success rounded-pill px-4 py-2 mt-2 fw-medium small"
        >
          Mua sắm ngay
        </button>
      </div>

      <!-- Cart Content -->
      <div v-else class="row g-4">

        <!-- Left: Cart Items -->
        <div class="col-12 col-lg-8">
          <div class="d-flex flex-column gap-3">
            <div
              v-for="item in cartItems" :key="item.cartItemId"
              class="bg-white rounded-xl border shadow-sm p-3 d-flex flex-column flex-sm-row align-items-start align-items-sm-center justify-content-between gap-3"
              style="border-color:#f3f4f6; transition:box-shadow 0.2s;"
            >
              <!-- Image & Info -->
              <div class="d-flex align-items-center gap-3 flex-grow-1 min-w-0 w-100">
                <div
                  class="rounded-xl overflow-hidden flex-shrink-0 border"
                  style="width:76px;height:76px;border-color:#f3f4f6;"
                >
                  <img :src="item.image" :alt="item.name" class="w-100 h-100 object-cover" loading="lazy" />
                </div>
                <div class="min-w-0">
                  <h3 class="fw-bold text-dark truncate small mb-0">{{ item.name }}</h3>
                  <span
                    v-if="item.tag"
                    :class="[item.tagColor, 'badge rounded mt-1']"
                    style="font-size:0.65rem;"
                  >{{ item.tag }}</span>
                  <p class="text-muted truncate mb-0" style="font-size:0.7rem;">{{ item.description }}</p>
                </div>
              </div>

              <!-- Actions: Quantity, Price, Remove -->
              <div
                class="d-flex align-items-center justify-content-between justify-content-sm-end gap-3 w-100 w-sm-auto pt-2 pt-sm-0 border-top border-top-sm-0"
                style="border-color:#f3f4f6;"
              >
                <!-- Quantity -->
                <div
                  class="d-flex align-items-center border rounded-xl overflow-hidden flex-shrink-0"
                  style="border-color:#e5e7eb;"
                >
                  <button
                    @click="decreaseQty(item)"
                    class="btn btn-sm border-0 px-2 text-muted fw-bold"
                    :class="{ 'opacity-50': item.quantity <= 1 }"
                  >−</button>
                  <span
                    class="px-2 small fw-bold text-dark"
                    style="background:#f9fafb;border-left:1px solid #e5e7eb;border-right:1px solid #e5e7eb;min-width:32px;text-align:center;line-height:32px;"
                  >{{ item.quantity }}</span>
                  <button
  @click="increaseQty(item)"
  class="btn btn-sm border-0 px-2 text-muted fw-bold"
  :disabled="item.maxQuantity > 0 && item.quantity >= item.maxQuantity"
  :class="{ 'opacity-50': item.maxQuantity > 0 && item.quantity >= item.maxQuantity }"
  :title="item.maxQuantity > 0 && item.quantity >= item.maxQuantity ? `Tối đa ${item.maxQuantity} combo` : ''"
>+</button>
                </div>

                <!-- Price & Remove -->
                <div class="d-flex align-items-center gap-3">
                  <div class="text-end" style="min-width:90px;">
                    <p class="fw-extrabold text-dark small mb-0">{{ formatPrice(item.price * item.quantity) }}</p>
                    <p v-if="item.quantity > 1" class="text-muted mb-0" style="font-size:0.65rem;">
                      {{ formatPrice(item.price) }}/combo
                    </p>
                  </div>
                  <button
                    @click="confirmDelete(item)"
                    class="btn btn-sm text-muted rounded-xl border-0 p-1"
                    :aria-label="'Xóa ' + item.name"
                  >
                    <TrashIcon style="width:16px;height:16px;" />
                  </button>
                </div>
              </div>
            </div>

            <!-- Continue Shopping -->
            <button
              @click="$emit('navigate', 'products')"
              class="btn btn-link text-success fw-medium text-decoration-none small d-inline-flex align-items-center gap-1"
            >
              ← Tiếp tục mua sắm
            </button>
          </div>
        </div>

        <!-- Right: Order Summary -->
        <div class="col-12 col-lg-4">
          <div
            class="bg-white rounded-xl border shadow-sm p-4 sticky-top"
            style="top:80px;border-color:#f3f4f6;"
          >
            <h2 class="fw-extrabold text-dark mb-4 pb-3 border-bottom small">Tóm tắt đơn hàng</h2>

            <div class="d-flex flex-column gap-2 small mb-3">
              <div class="d-flex justify-content-between text-muted">
                <span>Tổng tiền</span>
                <span class="fw-semibold text-dark">{{ formatPrice(subtotal) }}</span>
              </div>
              <div class="d-flex justify-content-between text-muted">
                <span>Phí giao hàng</span>
                <span class="fw-semibold text-dark">{{ formatPrice(SHIPPING_FEE) }}</span>
              </div>
            </div>

            <div class="border-top border-dashed pt-3 mb-4">
              <div class="d-flex justify-content-between align-items-baseline">
                <span class="fw-bold text-dark small">Thành tiền</span>
                <div class="text-end">
                  <span class="fw-extrabold text-success" style="font-size:1.2rem;">{{ formatPrice(total) }}</span>
                  <p class="text-muted mb-0" style="font-size:0.65rem;">(Đã bao gồm VAT)</p>
                </div>
              </div>
            </div>

            <button @click="openCheckout" class="btn btn-success w-100 rounded-xl fw-bold py-2 shadow-success">
              Đặt hàng
            </button>
            <p class="text-muted text-center mt-2 mb-4" style="font-size:0.65rem;line-height:1.5;">
              Bằng cách nhấn đặt hàng, bạn đồng ý<br>với các điều khoản dịch vụ của FreshFarm.
            </p>

            <!-- Shipping Info -->
            <div
              class="p-3 rounded-xl d-flex align-items-start gap-2"
              style="background:#f9fafb;border:1px solid #f3f4f6;"
            >
              <div class="p-1 rounded-circle flex-shrink-0 mt-1" style="background:#ebf2ee;">
                <TruckIcon style="width:14px;height:14px;color:#4e7c66;" />
              </div>
              <div>
                <p class="fw-bold text-dark mb-0" style="font-size:0.75rem;">Giao hàng nhanh</p>
                <p class="text-muted mb-0" style="font-size:0.65rem;line-height:1.5;">
                  Dự kiến nhận hàng trong 24h tại khu vực nội thành.
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Checkout Modal -->
    <Teleport to="body">
      <div v-if="showCheckoutModal" class="ff-modal-overlay" @click="showCheckoutModal = false">
        <div class="ff-modal-box" @click.stop style="max-width:36rem;">

          <!-- Header -->
          <div class="p-4 border-bottom d-flex justify-content-between align-items-center bg-light">
            <h3 class="fw-extrabold text-dark mb-0" style="font-size:1.1rem;">Thông tin giao hàng</h3>
            <button
              @click="showCheckoutModal = false"
              class="btn btn-sm btn-outline-secondary rounded-xl border"
            >
              <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
          </div>

          <!-- Content -->
          <div class="p-4 overflow-auto">
            <div class="d-flex flex-column gap-3 mb-4">
              <div>
                <label class="form-label fw-semibold small">
                  Họ và tên <span class="text-danger">*</span>
                </label>
                <input
                  v-model="orderForm.fullName"
                  type="text"
                  placeholder="Nhập họ và tên người nhận (3 - 50 ký tự)"
                  class="form-control rounded-xl"
                  maxlength="50"
                />
              </div>
              <div>
                <label class="form-label fw-semibold small">
                  Số điện thoại <span class="text-danger">*</span>
                </label>
                <input
                  v-model="orderForm.phone"
                  type="tel"
                  placeholder="Nhập số điện thoại 10 chữ số"
                  class="form-control rounded-xl"
                  maxlength="10"
                />
              </div>
              <div>
                <label class="form-label fw-semibold small">
                  Địa chỉ giao hàng <span class="text-danger">*</span>
                </label>
                <textarea
                  v-model="orderForm.address"
                  rows="2"
                  placeholder="Nhập địa chỉ giao hàng chi tiết (10 - 255 ký tự)"
                  class="form-control rounded-xl resize-none"
                  maxlength="255"
                ></textarea>
              </div>
            </div>

            <!-- Payment Methods -->
            <h4 class="fw-bold text-dark small mb-3">Phương thức thanh toán</h4>
            <div class="d-flex flex-column gap-3 mb-4">
              <label
                class="d-flex align-items-center gap-3 p-3 border rounded-xl"
                :class="orderForm.paymentMethod === 'COD' ? 'border-success bg-success bg-opacity-10' : ''"
                style="cursor:pointer;"
              >
                <input type="radio" v-model="orderForm.paymentMethod" value="COD" class="form-check-input m-0" />
                <div class="flex-grow-1">
                  <div class="fw-bold text-dark small">Thanh toán khi nhận hàng (COD)</div>
                  <div class="text-muted" style="font-size:0.75rem;">Nhận hàng và thanh toán trực tiếp cho shipper</div>
                </div>
                <span style="font-size:1.4rem;">💵</span>
              </label>
              <label
                class="d-flex align-items-center gap-3 p-3 border rounded-xl"
                :class="orderForm.paymentMethod === 'VNPAY' ? 'border-success bg-success bg-opacity-10' : ''"
                style="cursor:pointer;"
              >
                <input type="radio" v-model="orderForm.paymentMethod" value="VNPAY" class="form-check-input m-0" />
                <div class="flex-grow-1">
                  <div class="fw-bold text-dark small">Thanh toán qua VNPay</div>
                  <div class="text-muted" style="font-size:0.75rem;">Thanh toán an toàn qua ví VNPay hoặc thẻ ngân hàng</div>
                </div>
                <img
                  :src="vnpayLogo"
                  alt="VNPay"
                  style="width:40px;height:28px;object-fit:contain;"
                />
              </label>
            </div>

            <!-- Order Summary -->
            <div
              class="p-3 rounded-xl d-flex flex-column gap-2"
              style="background:#f9fafb;border:1px solid #f3f4f6;"
            >
              <div class="d-flex justify-content-between align-items-center">
                <span class="small text-muted fw-medium">Phí vận chuyển:</span>
                <span class="fw-semibold text-dark small">{{ formatPrice(SHIPPING_FEE) }}</span>
              </div>
              <div class="d-flex justify-content-between align-items-center border-top pt-2 mt-1 border-dashed">
                <span class="small text-dark fw-bold">Tổng thanh toán:</span>
                <span class="fw-extrabold text-success" style="font-size:1.1rem;">{{ formatPrice(total) }}</span>
              </div>
            </div>
          </div>

          <!-- Footer -->
          <div class="p-4 border-top bg-white d-flex gap-3">
            <button
              @click="showCheckoutModal = false"
              class="btn btn-light flex-grow-1 rounded-xl fw-bold py-2"
            >
              Hủy
            </button>
            <button
              @click="submitOrder"
              :disabled="isProcessing"
              class="btn btn-success flex-grow-1 rounded-xl fw-bold py-2 d-flex align-items-center justify-content-center gap-2"
            >
              <span v-if="isProcessing" class="spinner-border spinner-border-sm"></span>
              {{ isProcessing ? 'Đang xử lý...' : 'Xác nhận Đặt Hàng' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- Hộp thoại xác nhận xóa sản phẩm -->
    <Teleport to="body">
      <div v-if="showDeleteConfirm" class="ff-modal-overlay" @click="showDeleteConfirm = false">
        <div class="ff-modal-box" @click.stop style="max-width:28rem;">
          <!-- Header -->
          <div class="p-4 border-bottom d-flex justify-content-between align-items-center bg-light">
            <h3 class="fw-extrabold text-dark mb-0" style="font-size:1.1rem;">Xác nhận xóa sản phẩm</h3>
            <button
              @click="showDeleteConfirm = false"
              class="btn btn-sm btn-outline-secondary rounded-xl border"
            >
              <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
          </div>
          
          <!-- Content -->
          <div class="p-4 text-center">
            <div class="text-warning mb-3" style="font-size:3rem;">⚠️</div>
            <p class="text-dark fw-bold mb-2">
              Bạn có chắc chắn muốn xóa sản phẩm này khỏi giỏ hàng không?
            </p>
            <p class="text-muted small mb-0" v-if="itemToDelete">
              Sản phẩm: <span class="fw-semibold text-danger">{{ itemToDelete.name }}</span>
            </p>
          </div>

          <!-- Footer -->
          <div class="p-4 border-top bg-white d-flex gap-3">
            <button
              @click="showDeleteConfirm = false"
              class="btn btn-light flex-grow-1 rounded-xl fw-bold py-2"
            >
              Hủy
            </button>
            <button
              @click="executeDelete"
              class="btn btn-danger flex-grow-1 rounded-xl fw-bold py-2"
            >
              Đồng ý xóa
            </button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<style scoped>
.ff-modal-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 1050;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
}
.ff-modal-box {
  background: white;
  width: 100%;
  border-radius: 1rem;
  overflow: hidden;
  box-shadow: 0 10px 25px rgba(0,0,0,0.1);
}
.rounded-xl  { border-radius: 0.75rem !important; }
.rounded-2xl { border-radius: 1rem !important; }
.object-cover { object-fit: cover; }
.resize-none  { resize: none; }

@media (min-width: 576px) {
  .border-top-sm-0 {
    border-top: 0 !important;
  }
}
</style>