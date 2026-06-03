import { ref, computed } from 'vue'
import apiClient from '@/api/axios'
import { toast } from '@/utils/toast'

const cartItems = ref([])
const cartTotalAmount = ref(0)
const cartId = ref(null)
const isLoadingCart = ref(false)

const BASE_URL = import.meta.env.VITE_API_URL || window.location.origin

function getImageUrl(url) {
  if (!url) return ''
  if (url.startsWith('http')) return url
  return `${BASE_URL}${url.startsWith('/') ? '' : '/'}${url}`
}

const saveLocalCart = () => {
  localStorage.setItem('cart', JSON.stringify(cartItems.value))
}

const generateLocalId = () =>
  `local_${Date.now()}_${Math.random().toString(36).slice(2)}`

export function useCart() {
  const isGuest = () => !localStorage.getItem('token')

  const isAdmin = () => {
    const token = localStorage.getItem('token')
    if (!token) return false
    try {
      const base64Url = token.split('.')[1]
      const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/')
      const payload = JSON.parse(
        decodeURIComponent(
          atob(base64).split('').map(c => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2)).join('')
        )
      )
      const role =
        payload['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ||
        payload['role']
      return role === 'Admin'
    } catch {
      return false
    }
  }

  // ── Fetch giỏ hàng ────────────────────────────────────────────────────
  const fetchCart = async () => {
    const localData = JSON.parse(localStorage.getItem('cart') || '[]')
    cartItems.value = localData.map(item => ({
      ...item,
      cartItemId: item.cartItemId || generateLocalId()
    }))

    if (!isGuest() && !isAdmin()) {
      isLoadingCart.value = true
      try {
        const response = await apiClient.get('/Cart/my-cart')
        const data = response.data.data || response.data

        const itemsList = data.items || data.Items
        if (data && Array.isArray(itemsList) && itemsList.length > 0) {
          cartId.value = data.cartId || data.CartId
          cartTotalAmount.value = data.totalAmount || data.TotalAmount

          cartItems.value = itemsList.map(item => ({
            cartItemId: item.cartItemId || item.CartItemId || item.id || item.Id || generateLocalId(),
            packageId:  item.packageId  || item.PackageId,
            name:       item.packageName || item.PackageName || item.name || item.Name,
            price:      item.price      || item.Price,
            quantity:   item.quantity   || item.Quantity,
            // ✅ Map maxQuantity từ API — dùng để giới hạn tăng số lượng ở FE
            maxQuantity: item.maxQuantity || item.MaxQuantity || 0,
            image: (item.imageUrl || item.ImageUrl)
              ? getImageUrl(item.imageUrl || item.ImageUrl)
              : 'https://images.unsplash.com/photo-1540420773420-3366772f4999?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80'
          }))
          saveLocalCart()
        } else if (data && Array.isArray(itemsList) && itemsList.length === 0) {
          console.log('API giỏ hàng trống, giữ lại hàng ở LocalStorage')
        }
      } catch (error) {
        console.warn('Lỗi khi fetch giỏ hàng từ API:', error)
      } finally {
        isLoadingCart.value = false
      }
    }
  }

  // ── Thêm vào giỏ ─────────────────────────────────────────────────────
  const addToCart = async (product, qty = 1) => {
    const packageId = product.packageId || product.productId || product.id
    const name      = product.packageName || product.productName || product.name
    const price     = product.discountPrice || product.basePrice || product.price
    const image     = getImageUrl(product.image)

    // Check maxQuantity
    const limit = product.maxQuantity !== undefined ? product.maxQuantity : (product.MaxQuantity !== undefined ? product.MaxQuantity : null)
    
    if (limit !== null) {
      const existing = cartItems.value.find(item => item.packageId === packageId)
      const currentQty = existing ? existing.quantity : 0
      if (limit <= 0) {
        toast.warning(`Sản phẩm "${name}" đã hết hạn mức bán theo Combo!`)
        return
      }
      if (currentQty + qty > limit) {
        toast.warning(`Bạn chỉ có thể mua tối đa ${limit} combo cho sản phẩm "${name}"! (Đã có ${currentQty} trong giỏ)`)
        return
      }
    }

    const existing = cartItems.value.find(item => item.packageId === packageId)
    if (existing) {
      existing.quantity += qty
    } else {
      cartItems.value.push({
        cartItemId: generateLocalId(),
        packageId,
        name,
        price,
        image,
        quantity: qty,
        maxQuantity: limit
      })
    }
    saveLocalCart()

    if (!isGuest()) {
      try {
        await apiClient.post('/Cart/add', { packageId, quantity: qty })
        // ✅ Fetch lại sau khi add để có maxQuantity mới nhất từ server
        await fetchCart()
      } catch (error) {
        // ✅ Hiển thị lỗi từ backend (ví dụ: không đủ tồn kho) thay vì nuốt lỗi
        let msg = 'Không thể thêm vào giỏ hàng.'
        if (error.response?.data) {
          const data = error.response.data
          if (data.message) msg = data.message
          else if (typeof data === 'string') msg = data
        }
        toast.error(msg)
        // ✅ Rollback lại item vừa thêm vào local nếu API lỗi
        if (existing) {
          existing.quantity -= qty
        } else {
          cartItems.value = cartItems.value.filter(i => i.packageId !== packageId)
        }
        saveLocalCart()
        return
      }
    }

    toast.success(`Đã thêm ${qty} x "${name}" vào giỏ hàng!`)
  }

  // ── Xóa khỏi giỏ ─────────────────────────────────────────────────────
  const removeFromCart = async (cartItemId) => {
    const targetItem = cartItems.value.find(
      item => String(item.cartItemId) === String(cartItemId)
    )
    if (!targetItem) return

    cartItems.value = cartItems.value.filter(
      item => String(item.packageId) !== String(targetItem.packageId)
    )
    saveLocalCart()

    if (!isGuest() && targetItem.cartItemId) {
      try {
        await apiClient.delete(`/Cart/remove/${targetItem.cartItemId}`)
      } catch (error) {
        console.warn('Lỗi sync xóa giỏ hàng với server:', error)
      }
    }
  }

  // ── Cập nhật số lượng ─────────────────────────────────────────────────
  const updateQuantity = async (cartItemId, newQuantity) => {
    if (newQuantity < 1) return

    const itemIndex = cartItems.value.findIndex(
      i => String(i.cartItemId) === String(cartItemId)
    )
    if (itemIndex === -1) return

    const item = cartItems.value[itemIndex]
    
    // Check maxQuantity
    const limit = item.maxQuantity !== undefined ? item.maxQuantity : (item.MaxQuantity !== undefined ? item.MaxQuantity : null)
    if (limit !== null && limit >= 0 && newQuantity > limit) {
      toast.warning(`Chỉ còn tối đa ${limit} combo cho sản phẩm "${item.name}"!`)
      return
    }

    item.quantity = newQuantity
    cartItems.value = [...cartItems.value]
    saveLocalCart()

    if (!isGuest()) {
      try {
        await apiClient.put('/Cart/update', {
          packageId: Number(item.packageId),
          PackageId: Number(item.packageId),
          quantity:  Number(newQuantity),
          Quantity:  Number(newQuantity)
        })
      } catch (error) {
        // ✅ Hiển thị lỗi từ backend nếu update thất bại
        let msg = 'Không thể cập nhật số lượng.'
        if (error.response?.data) {
          const data = error.response.data
          if (data.message) msg = data.message
          else if (typeof data === 'string') msg = data
        }
        toast.error(msg)
        // ✅ Fetch lại để đồng bộ số lượng đúng từ server
        await fetchCart()
      }
    }
  }

  // ✅ Check maxQuantity trước khi tăng — tránh gọi API khi biết chắc sẽ lỗi
  const increaseQty = (item) => {
    const limit = item.maxQuantity !== undefined ? item.maxQuantity : (item.MaxQuantity !== undefined ? item.MaxQuantity : null)
    if (limit !== null && limit >= 0 && item.quantity >= limit) {
      toast.warning(`Chỉ còn tối đa ${limit} combo trong kho!`)
      return
    }
    updateQuantity(item.cartItemId, item.quantity + 1)
  }

  const decreaseQty = (item) => {
    if (item.quantity > 1) updateQuantity(item.cartItemId, item.quantity - 1)
  }

  // ── Xóa toàn bộ giỏ ──────────────────────────────────────────────────
  const clearCart = async () => {
    const itemsToDelete = [...cartItems.value]

    cartItems.value = []
    cartTotalAmount.value = 0
    saveLocalCart()

    if (!isGuest() && itemsToDelete.length > 0) {
      try {
        await apiClient.delete('/Cart/clear')
      } catch (error) {
        if (error.response?.status === 404) {
          const promises = itemsToDelete.map(item =>
            apiClient.delete(`/Cart/remove/${item.cartItemId}`)
          )
          await Promise.allSettled(promises)
        } else {
          console.warn('Lỗi sync xóa giỏ hàng với server:', error)
        }
      }
    }
  }

  const cartCount = computed(() =>
    cartItems.value.reduce((total, item) => total + item.quantity, 0)
  )

  const cartSubtotal = computed(() =>
    cartItems.value.reduce((total, item) => total + item.price * item.quantity, 0)
  )

  return {
    cartItems,
    isLoadingCart,
    fetchCart,
    addToCart,
    removeFromCart,
    increaseQty,
    decreaseQty,
    updateQuantity,
    clearCart,
    cartCount,
    cartSubtotal
  }
}