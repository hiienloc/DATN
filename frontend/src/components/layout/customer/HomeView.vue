<script setup>
import { ref, onMounted } from 'vue'
import { ShoppingCartIcon, TruckIcon, ShieldCheckIcon, ClockIcon } from '@heroicons/vue/24/outline'
import apiClient from '@/api/axios'
import { useCart } from '@/composables/useCart'

const { addToCart } = useCart()
const emit = defineEmits(['navigate'])

const discountedProducts = ref([])
const featuredCombos = ref([])
const BASE_URL = import.meta.env.VITE_API_URL || window.location.origin

function getImageUrl(url) {
  if (!url) return ''
  if (url.startsWith('http')) return url
  return `${BASE_URL}${url.startsWith('/') ? '' : '/'}${url}`
}

const fetchDiscountedProducts = async () => {
  try {
    const response = await apiClient.get('/Package')
    let data = response.data.data || response.data || []
    
    discountedProducts.value = data
      .filter(item => {
        if (item.isActive === false) return false;
        const basePrice = item.price || 0;
        const discountPrice = item.discount || 0;
        const now = new Date();
        const start = item.startDate ? new Date(item.startDate) : null;
        const end = item.endDate ? new Date(item.endDate) : null;
        const isPromoActive = discountPrice > 0 && discountPrice < basePrice &&
          (!start || start <= now) && (!end || now <= end);
        return isPromoActive;
      })
      .slice(0, 8)
      .map(item => {
        const basePrice = item.price || 0;
        const discountPrice = item.discount || 0;
        const discountPercent = Math.round(((basePrice - discountPrice) / basePrice) * 100);
        return {
          ...item,
          productId: item.packageId || item.id,
          productName: item.packageName || item.name,
          price: basePrice,
          discountPrice: discountPrice,
          discountPercent: discountPercent,
          image: item.imageUrl || item.image,
          unit: item.unit || '1kg'
        }
      })
  } catch (error) {
    console.error('Lỗi khi tải combo giảm giá:', error)
  }
}

const fetchCombos = async () => {
  try {
    const response = await apiClient.get('/Package')
    let data = response.data.data || response.data || []
    
    featuredCombos.value = data.filter(item => item.isActive !== false).slice(0, 4).map(item => {
      const basePrice = item.price || 0
      const discountPrice = item.discount || 0
      const now = new Date();
      const start = item.startDate ? new Date(item.startDate) : null;
      const end = item.endDate ? new Date(item.endDate) : null;
      const isPromoActive = discountPrice > 0 && discountPrice < basePrice &&
        (!start || start <= now) && (!end || now <= end);
      const hasDiscount = isPromoActive
      const finalPrice = hasDiscount ? discountPrice : basePrice
      
      return {
        ...item,
        id: item.packageId,
        price: finalPrice,
        originalPrice: hasDiscount ? basePrice : null,
        image: getImageUrl(item.imageUrl),
        tag: hasDiscount ? `Giảm ${Math.round(((basePrice - discountPrice) / basePrice) * 100)}%` : null,
        unit: item.unit || '1kg'
      }
    })
  } catch (error) {
    console.error('Lỗi khi tải combo:', error)
  }
}

const formatPrice = (price) => new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(price)

onMounted(() => {
  fetchDiscountedProducts()
  fetchCombos()
  document.title = 'FreshFarm | Nông sản sạch & Thực phẩm hữu cơ cho gia đình bạn'
})
</script>

<template>
  <div style="">
    <!-- Hero Banner (Full-Width, Flat Sharp Corners like Oddbox) -->
    <section aria-labelledby="hero-heading" class="ff-hero" style="height:250px;">
      <img
        src="https://images.unsplash.com/photo-1488459716781-31db52582fe9?ixlib=rb-1.2.1&auto=format&fit=crop&w=1600&q=80"
        alt="Nông trại rau củ hữu cơ tươi xanh FreshFarm đạt chuẩn VietGAP"
        fetchpriority="high"
      />
      <div class="ff-hero-overlay"></div>
      <div class="ff-hero-content d-flex align-items-center h-100">
        <div class="container-xl px-3 px-sm-4">
          <div style="max-width:550px;">
            <span class="badge rounded-pill mb-2 d-inline-flex align-items-center gap-1"
              style="background:rgba(12,92,54,0.3);color:#c5ff6d;border:1px solid rgba(197,255,109,0.3);font-size:0.7rem;padding:4px 10px;">
              🌱 100% Nông sản hữu cơ đạt chuẩn VietGAP
            </span>
            <h1 id="hero-heading" class="text-white fw-bold lh-sm mb-2" style="font-size:clamp(1.4rem, 3vw, 2rem); ">
              Tươi ngon từ nông trại <br>
              <span style="color:#c5ff6d; background: linear-gradient(120deg, #c5ff6d, #10b981); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">đến bàn ăn gia đình bạn</span>
            </h1>
            <p class="d-none d-md-block text-white-50 mb-2" style="font-size:0.85rem; line-height:1.4;">
              Combo nông sản sạch, giao hàng nhanh trong 2 giờ. An toàn cho sức khỏe và tiết kiệm cho cả gia đình.
            </p>
            <div class="d-flex flex-wrap gap-2">
              <a href="#" @click.prevent="$emit('navigate', 'products')"
                class="btn btn-success rounded-pill fw-semibold"
                style="padding: 6px 18px !important; font-size: 0.85rem;">
                Mua sắm ngay
              </a>
              <a href="#combos" class="btn btn-outline-light rounded-pill fw-semibold" style="backdrop-filter:blur(8px); padding: 6px 18px !important; font-size: 0.85rem;">
                Xem combo →
              </a>
            </div>
          </div>
        </div>
      </div>
    </section>
  
    <!-- Flat Full-Width Features Bar (Flush to Hero) -->
    <section aria-label="Lợi ích khi mua hàng" style="background:#2E7D32;" class="py-2 mb-2 border-top border-bottom border-success-subtle">
      <div class="container-xl px-3 px-sm-4">
        <div class="row row-cols-1 row-cols-md-3 g-2 text-center text-md-start">
          <div class="col">
            <div class="d-flex align-items-center justify-content-center justify-content-md-start gap-2 text-white">
              <div class="p-1 rounded-circle" style="background:rgba(255,255,255,0.12); display: flex; align-items: center; justify-content: center;">
                <TruckIcon style="width:20px;height:20px;color:#c5ff6d;" aria-hidden="true" />
              </div>
              <div>
                <h3 class="fw-bold fs-6 mb-0" style="font-size: 0.85rem !important;">Giao hàng siêu tốc</h3>
                <p class="mb-0 text-white-50" style="font-size:0.7rem;">Trong vòng 2 giờ nội thành</p>
              </div>
            </div>
          </div>
          <div class="col">
            <div class="d-flex align-items-center justify-content-center justify-content-md-start gap-2 text-white">
              <div class="p-1 rounded-circle" style="background:rgba(255,255,255,0.12); display: flex; align-items: center; justify-content: center;">
                <ShieldCheckIcon style="width:20px;height:20px;color:#c5ff6d;" aria-hidden="true" />
              </div>
              <div>
                <h3 class="fw-bold fs-6 mb-0" style="font-size: 0.85rem !important;">Chất lượng đảm bảo</h3>
                <p class="mb-0 text-white-50" style="font-size:0.7rem;">Đạt tiêu chuẩn VietGAP, GlobalGAP</p>
              </div>
            </div>
          </div>
          <div class="col">
            <div class="d-flex align-items-center justify-content-center justify-content-md-start gap-2 text-white">
              <div class="p-1 rounded-circle" style="background:rgba(255,255,255,0.12); display: flex; align-items: center; justify-content: center;">
                <ClockIcon style="width:20px;height:20px;color:#c5ff6d;" aria-hidden="true" />
              </div>
              <div>
                <h3 class="fw-bold fs-6 mb-0" style="font-size: 0.85rem !important;">Hỗ trợ 24/7</h3>
                <p class="mb-0 text-white-50" style="font-size:0.7rem;">Luôn sẵn sàng giải đáp thắc mắc</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Discounted Products Section -->
    <section aria-labelledby="promotions-heading" class="container-xl px-3 px-sm-4 pt-0 pb-3 mb-3">
      <div class="d-flex justify-content-between align-items-end mb-4">
        <div>
          <span class="text-success fw-bold text-uppercase" style="font-size: 0.75rem; letter-spacing: 0.1em;">Ưu đãi hôm nay</span>
          <h2 id="promotions-heading" class="fw-bold text-dark mb-1" style="font-size:1.6rem; ">🎉 Khuyến mãi đặc biệt</h2>
        </div>
        <a href="#" @click.prevent="$emit('navigate', 'products')" class="text-success text-decoration-none small fw-semibold d-flex align-items-center gap-1">
          Xem tất cả <span style="font-size:1.1rem;">→</span>
        </a>
      </div>

      <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4">
        <div class="col" v-for="product in discountedProducts" :key="product.productId">
          <article class="ff-modern-card" @click="$emit('navigate', 'products')">
            <!-- Image Wrapper -->
            <div class="ff-card-img-wrapper">
              <div class="ff-badge-discount">
                -{{ product.discountPercent }}%
              </div>
              <!-- Brand Badge -->
              <div class="ff-card-brand-overlay">
                <div class="d-flex align-items-center gap-1">
                  <img src="https://cdn-icons-png.flaticon.com/512/1514/1514935.png" alt="FreshFarm Icon" />
                  <span class="fw-bold text-success" style="font-size:0.6rem; text-shadow: 1px 1px 0 #fff;">freshfarm.vn</span>
                </div>
              </div>
              <img :src="getImageUrl(product.image)" :alt="'Nông sản sạch: ' + product.productName" loading="lazy" class="w-100 h-100" />
            </div>
            <!-- Content -->
            <div class="ff-card-body">
              <h3 class="ff-card-title">{{ product.productName }}</h3>
              
              <div class="ff-card-footer">
                <div>
                  <span class="ff-price-discounted">{{ formatPrice(product.discountPrice) }}</span>
                  <span class="ff-price-original" v-if="product.price">{{ formatPrice(product.price) }}</span>
                </div>
                <button @click.stop="addToCart(product)" :aria-label="'Thêm ' + product.productName + ' vào giỏ hàng'" class="ff-card-btn-add">
                  <ShoppingCartIcon style="width:18px;height:18px;" aria-hidden="true" />
                </button>
              </div>
            </div>
          </article>
        </div>
      </div>
    </section>

    <!-- Featured Combos Section -->
    <section id="combos" aria-labelledby="combos-heading" class="py-5" style="background: transparent;">
      <div class="container-xl px-3 px-sm-4">
        <div class="d-flex justify-content-between align-items-end mb-4">
          <div>
            <span class="text-success fw-bold text-uppercase" style="font-size: 0.75rem; letter-spacing: 0.1em;">Tiết kiệm hơn</span>
            <h2 id="combos-heading" class="fw-bold text-dark mb-1" style="font-size:1.6rem; ">🌿 Combo Tiết Kiệm</h2>
          </div>
          <a href="#" @click.prevent="$emit('navigate', 'products')" class="text-success text-decoration-none small fw-semibold d-flex align-items-center gap-1">
            Xem tất cả combo <span style="font-size:1.1rem;">→</span>
          </a>
        </div>

        <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4">
          <div class="col" v-for="combo in featuredCombos" :key="combo.packageId">
            <article class="ff-modern-card" @click="$emit('navigate', 'products')">
              <!-- Image Wrapper -->
              <div class="ff-card-img-wrapper">
                <div v-if="combo.tag" class="ff-badge-tag">
                  {{ combo.tag }}
                </div>
                <!-- Brand Badge -->
                <div class="ff-card-brand-overlay">
                  <div class="d-flex align-items-center gap-1">
                    <img src="https://cdn-icons-png.flaticon.com/512/1514/1514935.png" alt="FreshFarm Icon" />
                    <span class="fw-bold text-success" style="font-size:0.6rem; text-shadow: 1px 1px 0 #fff;">freshfarm.vn</span>
                  </div>
                </div>
                <img :src="combo.image" :alt="'Combo thực phẩm sạch: ' + combo.packageName" loading="lazy" class="w-100 h-100" />
              </div>
              <!-- Content -->
              <div class="ff-card-body">
                <h3 class="ff-card-title">{{ combo.packageName }}</h3>
                
                <div class="ff-card-footer">
                  <div>
                    <span class="ff-price-discounted">{{ formatPrice(combo.price) }}</span>
                    <span class="ff-price-original" v-if="combo.originalPrice">{{ formatPrice(combo.originalPrice) }}</span>
                  </div>
                  <button @click.stop="addToCart(combo)" :aria-label="'Thêm ' + combo.packageName + ' vào giỏ hàng'" class="ff-card-btn-add">
                    <ShoppingCartIcon style="width:18px;height:18px;" aria-hidden="true" />
                  </button>
                </div>
              </div>
            </article>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>
