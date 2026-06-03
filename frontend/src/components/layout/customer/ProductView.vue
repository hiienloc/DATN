<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { HeartIcon } from '@heroicons/vue/24/outline'
import { ChevronLeftIcon, ChevronRightIcon, ShoppingCartIcon } from '@heroicons/vue/24/solid'
import { useCart } from '@/composables/useCart'
import apiClient from '@/api/axios'

const props = defineProps({
  searchQuery: { type: String, default: '' }
})

const { addToCart } = useCart()
const emit = defineEmits(['navigate', 'viewProduct'])

const combos = ref([])
const currentPage = ref(1)
const itemsPerPage = 10
const BASE_URL = import.meta.env.VITE_API_URL || window.location.origin

function getImageUrl(url) {
  if (!url) return ''
  if (url.startsWith('http')) return url
  return `${BASE_URL}${url.startsWith('/') ? '' : '/'}${url}`
}

const removeAccents = (str) => {
  return str ? str.normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd').replace(/Đ/g, 'D') : ''
}

const sortOrder = ref('default') // 'default', 'asc', 'desc'
const filteredCombos = computed(() => {
  const query = removeAccents(props.searchQuery).toLowerCase().trim()
  let result = combos.value
  if (query) {
    result = result.filter(c => {
      const nameMatch = removeAccents(c.name).toLowerCase().includes(query)
      const descMatch = removeAccents(c.description).toLowerCase().includes(query)
      const codeMatch = c.packageCode ? removeAccents(c.packageCode).toLowerCase().includes(query) : false
      return nameMatch || descMatch || codeMatch
    })
  }
  if (sortOrder.value === 'asc') {
    result = [...result].sort((a, b) => a.price - b.price)
  } else if (sortOrder.value === 'desc') {
    result = [...result].sort((a, b) => b.price - a.price)
  }
  return result
})

watch(() => props.searchQuery, () => {
  currentPage.value = 1
})

const totalPages = computed(() => Math.ceil(filteredCombos.value.length / itemsPerPage))

const paginatedCombos = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  return filteredCombos.value.slice(start, start + itemsPerPage)
})

const visiblePages = computed(() => {
  const total = totalPages.value
  const current = currentPage.value
  const pages = []
  if (total <= 5) {
    for (let i = 1; i <= total; i++) pages.push(i)
  } else {
    let start = Math.max(1, current - 2)
    let end = Math.min(total, current + 2)
    if (current <= 3) { start = 1; end = 5 }
    if (current >= total - 2) { start = total - 4; end = total }
    for (let i = start; i <= end; i++) pages.push(i)
  }
  return pages
})

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }
}
const prevPage = () => goToPage(currentPage.value - 1)
const nextPage = () => goToPage(currentPage.value + 1)

const fetchCombos = async () => {
  try {
    const response = await apiClient.get('/Package')
    let data = response.data.data || response.data || []
    
    combos.value = data.filter(item => item.isActive !== false).map(item => {
      const basePrice = item.price || 0
      const discountPrice = item.discount || 0
      
      const now = new Date()
      const start = item.startDate ? new Date(item.startDate) : null
      const end = item.endDate ? new Date(item.endDate) : null
      const isPromoActive = discountPrice > 0 && discountPrice < basePrice &&
        (!start || start <= now) && (!end || now <= end);
      const hasDiscount = isPromoActive
      const finalPrice = hasDiscount ? discountPrice : basePrice
      
      const discountPercent = hasDiscount ? Math.round(((basePrice - discountPrice) / basePrice) * 100) : 0

      return {
        ...item,
        id: item.packageId,
        name: item.packageName,
        description: item.description,
        price: finalPrice,
        originalPrice: hasDiscount ? basePrice : null,
        image: getImageUrl(item.imageUrl),
        tag: hasDiscount ? `Giảm ${discountPercent}%` : null,
        unit: item.unit || '1kg',
        qty: 1
      }
    })
  } catch (error) {
    console.error('Lỗi khi tải combo:', error)
  }
}

onMounted(() => { fetchCombos() })

const formatPrice = (price) => new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(price)
</script>

<template>
  <div class="container-xl px-3 px-sm-4 py-4">

    <!-- Sort & Search Badge -->
    <div class="d-flex flex-wrap align-items-center gap-3 mb-4">
      <div v-if="searchQuery" class="d-flex align-items-center gap-2">
        <span class="text-muted small">Kết quả tìm kiếm cho:</span>
        <span class="badge rounded-pill bg-success bg-opacity-10 text-success border border-success-subtle px-3 py-2 fw-semibold" style="font-size:0.85rem;">
          "{{ searchQuery }}"
        </span>
        <span class="text-muted small">({{ filteredCombos.length }} kết quả)</span>
      </div>
      <div class="ms-auto d-flex align-items-center gap-2">
        <label class="small text-muted mb-0">Sắp xếp:</label>
        <select v-model="sortOrder" class="form-select form-select-sm" style="width:auto;min-width:120px;">
          <option value="default">Mặc định</option>
          <option value="asc">Giá tăng dần</option>
          <option value="desc">Giá giảm dần</option>
        </select>
      </div>
    </div>

    <!-- Empty State -->
    <div v-if="filteredCombos.length === 0" class="text-center py-5 my-4">
      <div style="font-size:3rem;" class="mb-3">🔍</div>
      <h3 class="fw-bold text-dark mb-2" style="font-size:1.15rem;">Không tìm thấy sản phẩm nào</h3>
      <p class="text-muted small mb-4" v-if="searchQuery">
        Không có combo nào khớp với từ khóa <strong>"{{ searchQuery }}"</strong>.<br>
        Hãy thử tìm với từ khóa khác.
      </p>
      <p class="text-muted small mb-4" v-else>Chưa có sản phẩm nào. Vui lòng quay lại sau.</p>
    </div>

    <!-- Product Grid -->
    <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-5 g-3">
      <div class="col" v-for="combo in paginatedCombos" :key="combo.id">
        <div class="card h-100" style="border: 1px solid #ebebeb; border-radius: 0; cursor:pointer; transition: box-shadow 0.2s;" @click="$emit('viewProduct', combo.id)" @mouseover="$event.currentTarget.classList.add('shadow-sm')" @mouseleave="$event.currentTarget.classList.remove('shadow-sm')">
          <!-- Image -->
          <div class="position-relative p-2" style="height:240px; background-color: white;">
            <div v-if="combo.tag" class="position-absolute top-0 start-0 m-2 badge bg-danger text-white rounded-0" style="z-index:1;font-size:0.75rem;">
              {{ combo.tag }}
            </div>
            <!-- FreshFarm Logo Overlay Giả lập -->
            <div class="position-absolute bottom-0 start-0 m-2" style="z-index:1; opacity: 0.9;">
              <div class="d-flex align-items-center gap-1">
                <img src="https://cdn-icons-png.flaticon.com/512/1514/1514935.png" style="width:20px;height:20px;filter:hue-rotate(90deg) drop-shadow(1px 1px 1px rgba(255,255,255,1));" />
                <span class="fw-bold" style="font-size:0.6rem;color:#2E7D32;text-shadow: 1px 1px 0 #fff, -1px -1px 0 #fff, 1px -1px 0 #fff, -1px 1px 0 #fff;">freshfarm.vn</span>
              </div>
            </div>
            <img :src="combo.image" :alt="combo.name" class="w-100 h-100" style="object-fit: contain;" />
          </div>
          <!-- Content -->
          <div class="card-body d-flex flex-column px-3 py-3 bg-white">
            <!-- Title -->
            <h3 class="card-title fw-bold text-uppercase mb-2" style=" font-size: 1.1rem; color: #111;">
              {{ combo.name }}
            </h3>
            
            <!-- Price and Cart Button -->
            <div class="mt-auto d-flex align-items-center justify-content-between">
              <div>
                <span class="fw-bold" style="color: #2E7D32; font-size: 1.15rem;">{{ formatPrice(combo.price) }}</span>
              </div>
              
              <button @click.stop="addToCart(combo)" class="btn border-0 rounded-2 p-0 d-flex align-items-center justify-content-center" style="background-color: #4CAF50; color: white; width: 34px; height: 34px; transition: transform 0.1s;" @mousedown="$event.currentTarget.style.transform='scale(0.95)'" @mouseup="$event.currentTarget.style.transform='scale(1)'" @mouseleave="$event.currentTarget.style.transform='scale(1)'">
                <ShoppingCartIcon style="width: 18px; height: 18px;" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Pagination -->
    <nav v-if="totalPages > 1" aria-label="Phân trang sản phẩm" class="mt-5 d-flex align-items-center justify-content-center gap-1">
      <!-- Prev -->
      <button @click="prevPage" :disabled="currentPage === 1"
        class="ff-page-btn d-flex align-items-center gap-1 px-3"
        :class="currentPage === 1 ? 'disabled' : ''">
        <ChevronLeftIcon style="width:16px;height:16px;" />
        <span class="d-none d-sm-inline">Trước</span>
      </button>

      <!-- First + ellipsis -->
      <template v-if="visiblePages[0] > 1">
        <button @click="goToPage(1)" class="ff-page-btn">1</button>
        <span v-if="visiblePages[0] > 2" class="text-muted px-1">…</span>
      </template>

      <!-- Pages -->
      <button v-for="page in visiblePages" :key="page" @click="goToPage(page)"
        class="ff-page-btn" :class="{ active: page === currentPage }">
        {{ page }}
      </button>

      <!-- Last + ellipsis -->
      <template v-if="visiblePages[visiblePages.length - 1] < totalPages">
        <span v-if="visiblePages[visiblePages.length - 1] < totalPages - 1" class="text-muted px-1">…</span>
        <button @click="goToPage(totalPages)" class="ff-page-btn">{{ totalPages }}</button>
      </template>

      <!-- Next -->
      <button @click="nextPage" :disabled="currentPage === totalPages"
        class="ff-page-btn d-flex align-items-center gap-1 px-3"
        :class="currentPage === totalPages ? 'disabled' : ''">
        <span class="d-none d-sm-inline">Sau</span>
        <ChevronRightIcon style="width:16px;height:16px;" />
      </button>
    </nav>

    <!-- Page info -->
    <p v-if="totalPages > 1" class="text-center text-muted mt-2" style="font-size:0.75rem;">
      Trang {{ currentPage }} / {{ totalPages }} · Hiển thị {{ paginatedCombos.length }} / {{ filteredCombos.length }} sản phẩm
    </p>
  </div>
</template>
