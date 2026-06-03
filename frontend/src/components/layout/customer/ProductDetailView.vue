<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import {
  ShoppingCartIcon, HeartIcon, TruckIcon, ShieldCheckIcon,
  ArrowLeftIcon, MinusIcon, PlusIcon, ChevronLeftIcon, ChevronRightIcon
} from '@heroicons/vue/24/outline'
import { useCart } from '@/composables/useCart'
import apiClient from '@/api/axios'

const { addToCart: storeAddToCart } = useCart()
const BASE_URL = import.meta.env.VITE_API_URL || window.location.origin

function getImageUrl(url) {
  if (!url) return ''
  if (url.startsWith('http')) return url
  return `${BASE_URL}${url.startsWith('/') ? '' : '/'}${url}`
}

const props = defineProps({ productId: { type: Number, default: 1 } })
const emit = defineEmits(['navigate', 'viewProduct'])

const allCombos = ref([])
const loading = ref(true)

const fetchProductData = async () => {
  loading.value = true
  try {
    const response = await apiClient.get('/Package')
    const data = response.data.data || response.data || []
    
    allCombos.value = data.filter(item => item.isActive !== false).map(item => {
      const basePrice = item.price || 0
      const discountPrice = item.discount || 0
      
      const now = new Date()
      const start = item.startDate ? new Date(item.startDate) : null
      const end = item.endDate ? new Date(item.endDate) : null
      const isPromoActive = discountPrice > 0 && discountPrice < basePrice &&
        (!start || start <= now) && (!end || now <= end);
      const hasDiscount = isPromoActive
      const finalPrice = hasDiscount ? discountPrice : basePrice

      const resolvedImage = getImageUrl(item.imageUrl)

      return {
        id: item.packageId,
        name: item.packageName,
        description: item.description || 'Chưa có mô tả ngắn',
        longDescription: item.description || 'Đang cập nhật mô tả chi tiết...',
        price: finalPrice,
        originalPrice: hasDiscount ? basePrice : null,
        image: resolvedImage,
        gallery: [resolvedImage],
        tag: hasDiscount ? `Giảm ${Math.round(((basePrice - discountPrice) / basePrice) * 100)}%` : null,
        rating: 5.0, 
        reviews: 120, 
        sold: 500,
        weight: 'Đóng gói theo combo',
        origin: 'FreshFarm Việt Nam',
        certification: 'VietGAP',
        items: item.items && item.items.length > 0
          ? item.items.map(i => `${i.productName || 'Sản phẩm'} (Số lượng: ${i.quantity})`)
          : ['Đang cập nhật thành phần...']
      }
    })
  } catch (error) {
    console.error('Lỗi lấy thông tin combo:', error)
  } finally {
    loading.value = false
  }
}

const product = computed(() => allCombos.value.find(c => c.id === props.productId) || allCombos.value[0] || {})
const otherCombos = computed(() => allCombos.value.filter(c => c.id !== product.value.id))
const carouselRef = ref(null)

const scrollCarousel = (direction) => {
  if (carouselRef.value) {
    const scrollAmount = 304 * direction
    carouselRef.value.scrollBy({ left: scrollAmount, behavior: 'smooth' })
  }
}

const addToCartDirect = (combo) => {
  storeAddToCart(combo, 1)
}

const selectedImage = ref(0)
const quantity = ref(1)

const reviews = ref([
  { id: 1, name: 'Nguyễn Thị Mai', rating: 5, date: '25/04/2026', comment: 'Rau rất tươi, đóng gói cẩn thận. Giao hàng nhanh trong 1.5 giờ. Sẽ đặt lại!', avatar: 'NM' },
  { id: 2, name: 'Trần Văn Hùng', rating: 4, date: '22/04/2026', comment: 'Chất lượng tốt, giá hợp lý. Cà rốt hơi nhỏ nhưng tổng thể hài lòng.', avatar: 'TH' },
  { id: 3, name: 'Lê Hoàng Anh', rating: 5, date: '18/04/2026', comment: 'Combo rất đáng tiền! Rau hữu cơ thật sự khác biệt, ăn ngon và an tâm.', avatar: 'LA' }
])

const discount = computed(() => {
  if (!product.value.originalPrice) return 0
  return Math.round((1 - product.value.price / product.value.originalPrice) * 100)
})

const increaseQty = () => quantity.value++
const decreaseQty = () => { if (quantity.value > 1) quantity.value-- }
const formatPrice = (price) => new Intl.NumberFormat('vi-VN').format(price) + 'đ'
const selectImage = (index) => { selectedImage.value = index }
const addToCart = () => { storeAddToCart(product.value, quantity.value) }
const buyNow = () => {
  storeAddToCart(product.value, quantity.value)
  emit('navigate', 'cart')
}

const viewProduct = (id) => {
  selectedImage.value = 0
  quantity.value = 1
  emit('viewProduct', id)
}

onMounted(() => { fetchProductData() })
watch(() => product.value, (newVal) => {
  if (newVal && newVal.name) document.title = `${newVal.name} | FreshFarm - Nông sản sạch`
}, { immediate: true })
</script>

<template>
  <div v-if="loading" class="min-vh-100 d-flex align-items-center justify-content-center" style="">
    <div class="text-success fw-bold animate-pulse">Đang tải chi tiết combo...</div>
  </div>
  <div v-else-if="!product.id" class="min-vh-100 d-flex align-items-center justify-content-center" style="">
    <div class="text-muted">Không tìm thấy sản phẩm.</div>
  </div>
  <div v-else class="container-xl px-3 px-sm-4 py-4" style="">
    <!-- Breadcrumb -->
    <nav aria-label="Breadcrumb" class="mb-4">
      <ol class="breadcrumb small text-muted">
        <li class="breadcrumb-item"><a href="#" @click.prevent="$emit('navigate', 'home')" class="text-muted text-decoration-none">Trang chủ</a></li>
        <li class="breadcrumb-item"><a href="#" @click.prevent="$emit('navigate', 'products')" class="text-muted text-decoration-none">Sản phẩm</a></li>
        <li class="breadcrumb-item active truncate" style="max-width:200px;">{{ product.name }}</li>
      </ol>
    </nav>

    <!-- Product Detail -->
    <div class="row g-5 mb-5 align-items-start">
      <!-- Left: Images -->
      <div class="col-12 col-lg-5">
        <div class="rounded-0 overflow-hidden border mb-3" style="aspect-ratio:1;border-color:#e5e7eb; background-color: #fff; border-radius: 0 !important;">
          <img :src="product.gallery[selectedImage]" :alt="product.name" class="w-100 h-100 object-cover" />
        </div>
        <div class="d-flex gap-2" v-if="product.gallery.length > 1">
          <button v-for="(img, index) in product.gallery" :key="index" @click="selectImage(index)"
            class="overflow-hidden border-2 flex-shrink-0 p-0"
            :class="selectedImage === index ? 'border-success' : 'border-light'"
            style="width:60px;height:60px; border-color: var(--ff-green) !important; border-radius: 0px !important;">
            <img :src="img" :alt="product.name" class="w-100 h-100 object-cover" />
          </button>
        </div>
      </div>

      <!-- Right: Info (Optimized Shopee-like Layout) -->
      <div class="col-12 col-lg-7">
        <!-- Title -->
        <h1 class="fw-bold text-dark lh-sm mb-2" style="font-size:clamp(1.3rem, 2.5vw, 1.8rem); ">
          <span>{{ product.name }}</span>
        </h1>



        <!-- Price block (Shopee Style) -->
        <div class="p-3 mb-4 rounded-2 d-flex align-items-center gap-3" style="background: rgba(46, 125, 50, 0.03); border: 1px solid rgba(46, 125, 50, 0.05);">
          <span v-if="product.originalPrice" class="text-muted text-decoration-line-through" style="font-size: 1.1rem !important;">{{ formatPrice(product.originalPrice) }}</span>
          <span class="fw-bold text-success" style="color: #2E7D32 !important; font-size: 1.9rem !important;">{{ formatPrice(product.price) }}</span>
          <span v-if="discount" class="badge rounded-1 py-1 px-2 fw-bold" style="background: #2E7D32; color: #c5ff6d; font-size: 0.7rem;">GIẢM {{ discount }}%</span>
        </div>

        <!-- Product Info (Shopee Style Grid) -->
        <div class="d-flex flex-column gap-3 mb-4 pb-3 border-bottom" style="font-size: 0.925rem;">
          <!-- Vận chuyển -->
          <div class="d-flex align-items-start">
            <span class="text-secondary" style="width:110px; flex-shrink:0;">Vận Chuyển</span>
            <div class="text-dark">
              <div class="d-flex align-items-center gap-2 fw-semibold text-success mb-1" style="color: #2E7D32 !important;">
                <TruckIcon style="width:18px;height:18px;" />
                <span>Giao hàng nhanh trong 2 giờ</span>
              </div>
              <div class="text-muted small">Miễn phí giao hàng cho đơn hàng từ 300.000đ nội thành.</div>
            </div>
          </div>
          
          <!-- Khối lượng -->
          <div class="d-flex align-items-center">
            <span class="text-secondary" style="width:110px; flex-shrink:0;">Khối Lượng</span>
            <span class="text-dark fw-medium">{{ product.weight }}</span>
          </div>

          <!-- Xuất xứ -->
          <div class="d-flex align-items-center">
            <span class="text-secondary" style="width:110px; flex-shrink:0;">Xuất Xứ</span>
            <span class="text-dark fw-medium">{{ product.origin }}</span>
          </div>

          <!-- Chứng nhận -->
          <div class="d-flex align-items-center">
            <span class="text-secondary" style="width:110px; flex-shrink:0;">Chứng Nhận</span>
            <span class="text-success fw-bold d-flex align-items-center gap-1" style="color: #2E7D32 !important;">
              <ShieldCheckIcon style="width:18px;height:18px;" /> {{ product.certification }}
            </span>
          </div>
        </div>

        <!-- Quantity (Shopee Style) -->
        <div class="d-flex align-items-center mb-4" style="font-size: 0.925rem;">
          <span class="text-secondary" style="width:110px; flex-shrink:0;">Số Lượng</span>
          <div class="d-flex align-items-center border rounded-1 overflow-hidden" style="border-color:#d1d5db;">
            <button @click="decreaseQty" class="btn btn-sm border-0 px-3 bg-light text-secondary" style="border-radius:0 !important; height:32px;" :class="{ 'opacity-50': quantity <= 1 }">
              <MinusIcon style="width:12px;height:12px;" />
            </button>
            <span class="px-3 small fw-bold text-dark text-center" style="min-width:48px; background:#fff; border-left:1px solid #d1d5db; border-right:1px solid #d1d5db; line-height:32px;">{{ quantity }}</span>
            <button @click="increaseQty" class="btn btn-sm border-0 px-3 bg-light text-secondary" style="border-radius:0 !important; height:32px;">
              <PlusIcon style="width:12px;height:12px;" />
            </button>
          </div>
        </div>

        <!-- Actions (Shopee Style Buttons) -->
        <div class="d-flex gap-3 mt-4">
          <button @click="addToCart" class="btn fw-semibold d-flex align-items-center justify-content-center gap-2" 
            style="background-color: rgba(46, 125, 50, 0.08); border: 1px solid #2E7D32; color: #2E7D32; padding: 12px 24px; font-size: 0.95rem; border-radius: 4px !important;">
            <ShoppingCartIcon style="width:20px;height:20px;" /> Thêm Vào Giỏ Hàng
          </button>
          <button @click="buyNow" class="btn fw-semibold text-white d-flex align-items-center justify-content-center" 
            style="background-color: #4CAF50; border: 1px solid #4CAF50; padding: 12px 36px; font-size: 0.95rem; border-radius: 4px !important;">
            Mua Ngay
          </button>
        </div>
      </div>
    </div>

    <!-- Description -->
    <div class="mb-5" style="max-width:48rem;">
      <h2 class="fw-bold text-dark mb-3 d-flex align-items-center gap-2">
        <div class="rounded-pill bg-success" style="width:4px;height:20px;"></div>
        Mô tả chi tiết
      </h2>
      <p class="small text-muted lh-lg">{{ product.longDescription }}</p>
    </div>

    <!-- Combo Items -->
    <div v-if="product.items && product.items.length > 0" class="mb-5 p-4 rounded-2xl" style="background:#f0fdf4;border:1px solid #dcfce7;">
      <h2 class="fw-bold text-dark mb-4 d-flex align-items-center gap-2">
        <div class="rounded-pill bg-success" style="width:4px;height:20px;"></div>
        Thành phần trong combo
      </h2>
      <div class="row g-3">
        <div class="col-12 col-sm-6" v-for="(item, index) in product.items" :key="index">
          <div class="d-flex align-items-center gap-3 bg-white rounded-xl px-3 py-2 border" style="border-color:#dcfce7;">
            <span class="d-flex align-items-center justify-content-center rounded-circle bg-success text-white fw-bold flex-shrink-0" style="width:24px;height:24px;font-size:0.65rem;">{{ index + 1 }}</span>
            <span class="small text-dark fw-medium">{{ item }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Related Products (Carousel Slider) -->
    <section aria-labelledby="related-heading" class="position-relative mt-5">
      <div class="d-flex align-items-center justify-content-between mb-4">
        <h2 id="related-heading" class="fw-bold text-dark mb-0" style="font-size:1.4rem;">Combo liên quan</h2>
        <!-- Navigation Buttons -->
        <div class="d-flex gap-2" v-if="otherCombos.length > 3">
          <button @click="scrollCarousel(-1)" class="btn rounded-circle p-0 d-flex align-items-center justify-content-center" style="width: 36px; height: 36px; border: 1px solid #2E7D32; color: #2E7D32; background: #fff; transition: all 0.2s;" @mouseover="$event.currentTarget.style.background='#e8f5e9'" @mouseleave="$event.currentTarget.style.background='#fff'" aria-label="Combo trước">
            <ChevronLeftIcon style="width: 20px; height: 20px;" />
          </button>
          <button @click="scrollCarousel(1)" class="btn rounded-circle p-0 d-flex align-items-center justify-content-center" style="width: 36px; height: 36px; border: 1px solid #2E7D32; color: #2E7D32; background: #fff; transition: all 0.2s;" @mouseover="$event.currentTarget.style.background='#e8f5e9'" @mouseleave="$event.currentTarget.style.background='#fff'" aria-label="Combo tiếp theo">
            <ChevronRightIcon style="width: 20px; height: 20px;" />
          </button>
        </div>
      </div>
      
      <!-- Scrolling Container -->
      <div ref="carouselRef" class="ff-carousel-container d-flex gap-4 overflow-x-auto pb-3" style="scroll-behavior: smooth; scrollbar-width: none; -ms-overflow-style: none;">
        <div class="ff-carousel-item flex-shrink-0" v-for="combo in otherCombos" :key="combo.id" style="width: 280px;">
          <article class="card ff-product-card border-0 h-100" @click="viewProduct(combo.id)" style="cursor:pointer; box-shadow: 0 4px 12px rgba(0,0,0,0.05); transition: transform 0.2s; border-radius: 4px !important;" @mouseover="$event.currentTarget.style.transform='translateY(-4px)'" @mouseleave="$event.currentTarget.style.transform='none'">
            <div class="overflow-hidden position-relative" style="height:180px; background: #fff;">
              <div v-if="combo.tag" class="position-absolute top-0 start-0 m-2 badge bg-danger text-white rounded-0" style="z-index:1;font-size:0.7rem;">{{ combo.tag }}</div>
              <img :src="combo.image" :alt="combo.name" loading="lazy" class="card-img-top object-cover w-100 h-100" style="object-fit: contain; padding: 10px;" />
            </div>
            <div class="card-body p-3 d-flex flex-column bg-white">
              <h3 class="card-title fw-bold text-dark mb-2 line-clamp-2" style="font-size: 0.95rem; line-height: 1.4; height: 2.7rem;">{{ combo.name }}</h3>
              <div class="mt-auto d-flex align-items-center justify-content-between">
                <div>
                  <span class="fw-bold text-success" style="color: #2E7D32 !important; font-size: 1.1rem;">{{ formatPrice(combo.price) }}</span>
                  <span v-if="combo.originalPrice" class="text-muted text-decoration-line-through small ms-2" style="font-size:0.75rem;">{{ formatPrice(combo.originalPrice) }}</span>
                </div>
                <button @click.stop="addToCartDirect(combo)" class="btn p-0 d-flex align-items-center justify-content-center" style="background: #4CAF50; color: white; width: 32px; height: 32px; border-radius: 4px;">
                  <ShoppingCartIcon style="width: 16px; height: 16px;" />
                </button>
              </div>
            </div>
          </article>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
.object-cover { object-fit: cover; }
.animate-pulse { animation: pulse 2s infinite; }
@keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: .5; } }
.truncate { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.line-clamp-1 { display: -webkit-box; -webkit-line-clamp: 1; -webkit-box-orient: vertical; overflow: hidden; }
.line-clamp-2 { display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
.rounded-2xl { border-radius: 1rem !important; }
.rounded-xl { border-radius: 0.75rem !important; }
.shadow-success { box-shadow: 0 4px 14px 0 rgba(25, 135, 84, 0.39); }
.ff-carousel-container::-webkit-scrollbar {
  display: none;
}
</style>
