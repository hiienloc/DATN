<script setup>
import { ref, computed, watch } from 'vue'
import { ShoppingCartIcon, MagnifyingGlassIcon, UserIcon, Bars3Icon } from '@heroicons/vue/24/outline'
import { useCart } from '@/composables/useCart'

const { cartCount } = useCart()

const props = defineProps({
  activeNav: { type: String, required: true },
  searchQuery: { type: String, default: '' }
})

const emit = defineEmits(['navigate', 'search'])

const localSearch = ref(props.searchQuery)
watch(() => props.searchQuery, (newVal) => {
  localSearch.value = newVal
})

const triggerSearch = () => {
  showMobileMenu.value = false
  showMobileSearch.value = false
  emit('search', localSearch.value)
}

const handleSearchInput = () => {
  // Nếu đang ở trang sản phẩm, filter real-time ngay khi gõ
  if (props.activeNav === 'products') {
    emit('search', localSearch.value)
  }
}

const showUserMenu = ref(false)
const showMobileSearch = ref(false)
const loggedOut = ref(false)

const userInfo = computed(() => {
  // eslint-disable-next-line no-unused-vars
  const _ = loggedOut.value
  try {
    const data = localStorage.getItem('user')
    return data ? JSON.parse(data) : null
  } catch { return null }
})

const isLoggedIn = computed(() => !!userInfo.value && !!localStorage.getItem('token'))
const userName = computed(() => userInfo.value?.fullName || 'Người dùng')

const isAdmin = computed(() => {
  const token = localStorage.getItem('token')
  if (!token) return false
  try {
    const base64Url = token.split('.')[1]
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/')
    const payload = JSON.parse(decodeURIComponent(atob(base64).split('').map(c => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2)).join('')))
    const role = payload["http://schemas.microsoft.com/ws/2008/06/identity/claims/role"] || payload["role"]
    return role === 'Admin'
  } catch { return false }
})

const userInitials = computed(() => {
  const name = userName.value
  const parts = name.trim().split(/\s+/)
  if (parts.length >= 2) return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
  return name.substring(0, 2).toUpperCase()
})

const toggleUserMenu = () => { showUserMenu.value = !showUserMenu.value }

const navigateAndClose = (page) => {
  showUserMenu.value = false
  emit('navigate', page)
}

const handleLogout = () => {
  localStorage.removeItem('token')
  localStorage.removeItem('user')
  loggedOut.value = !loggedOut.value
  showUserMenu.value = false
  emit('navigate', 'home')
}

const showMobileMenu = ref(false)
const navigateAndCloseMobile = (page) => {
  showMobileMenu.value = false
  emit('navigate', page)
}
</script>

<template>
  <div class="min-vh-100 d-flex flex-column w-100 position-relative" style="background:#f8fafc; ">
    <!-- Mobile Navigation Drawer -->
    <div class="ff-mobile-drawer" :class="{ open: showMobileMenu }">
      <div class="d-flex align-items-center justify-content-between pb-3 mb-3 border-bottom">
        <div class="d-flex align-items-center gap-2">
          <!-- Fresh Sprout SVG Icon -->
          <svg width="26" height="26" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style="flex-shrink:0;">
            <rect width="24" height="24" rx="7" fill="url(#logoBgGradDrawer)" />
            <path d="M12 5C12 5 15 8 15 11.5C15 15 12 18 12 18C12 18 9 15 9 11.5C9 8 12 5 12 5Z" fill="#ffffff" />
            <path d="M12 8V15" stroke="#2E7D32" stroke-width="0.8" stroke-linecap="round" opacity="0.3" />
            <path d="M13 10.5C13 10.5 15.5 10.5 16.5 12.5" stroke="#ffffff" stroke-width="1.2" stroke-linecap="round" />
            <defs>
              <linearGradient id="logoBgGradDrawer" x1="0" y1="0" x2="24" y2="24" gradientUnits="userSpaceOnUse">
                <stop stop-color="#c5ff6d" />
                <stop offset="1" stop-color="#2E7D32" />
              </linearGradient>
            </defs>
          </svg>
          <span class="fw-bold fs-5" style="color:#2E7D32;letter-spacing:-0.02em;">Fresh<span class="text-success" style="color:#4CAF50!important;">Farm</span></span>
        </div>
        <button @click="showMobileMenu = false" class="btn-close" aria-label="Đóng menu"></button>
      </div>
      <nav class="d-flex flex-column gap-3 mb-4" aria-label="Menu di động">
        <a href="#" @click.prevent="navigateAndCloseMobile('home')" class="text-decoration-none py-2 border-bottom text-dark fw-medium" :class="{ 'text-success': activeNav === 'home' }">Trang chủ</a>
        <a href="#" @click.prevent="navigateAndCloseMobile('products')" class="text-decoration-none py-2 border-bottom text-dark fw-medium" :class="{ 'text-success': activeNav === 'products' }">Sản phẩm</a>
        <a href="#" @click.prevent="navigateAndCloseMobile('about')" class="text-decoration-none py-2 border-bottom text-dark fw-medium" :class="{ 'text-success': activeNav === 'about' }">Về chúng tôi</a>
      </nav>
      <!-- Mobile Search inside Drawer -->
      <div class="input-group mt-auto">
        <input v-model="localSearch" @keyup.enter="triggerSearch" @input="handleSearchInput" type="text" placeholder="Tìm kiếm combo nông sản..." class="form-control rounded-start-pill border-end-0 bg-light" aria-label="Tìm kiếm sản phẩm di động" />
        <button @click="triggerSearch" class="btn btn-success rounded-end-pill px-3" aria-label="Nút tìm kiếm di động">
          🔍
        </button>
      </div>
    </div>
    
    <!-- Mobile Drawer Overlay -->
    <div class="ff-mobile-drawer-overlay" :class="{ open: showMobileMenu }" @click="showMobileMenu = false"></div>

    <!-- Navbar -->
    <header class="ff-navbar sticky-top" style="z-index:1030;">
      <div class="container-xl px-3 px-sm-4">
        <div class="d-flex align-items-center justify-content-between" style="height:72px;">
          <!-- Logo -->
          <a href="#" @click.prevent="$emit('navigate', 'home')" class="d-flex align-items-center gap-2 text-decoration-none" aria-label="Trang chủ FreshFarm">
            <!-- Fresh Sprout SVG Icon -->
            <svg width="34" height="34" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style="flex-shrink:0;">
              <rect width="24" height="24" rx="7" fill="url(#logoBgGrad)" />
              <path d="M12 5C12 5 15 8 15 11.5C15 15 12 18 12 18C12 18 9 15 9 11.5C9 8 12 5 12 5Z" fill="#ffffff" />
              <path d="M12 8V15" stroke="#2E7D32" stroke-width="0.8" stroke-linecap="round" opacity="0.3" />
              <path d="M13 10.5C13 10.5 15.5 10.5 16.5 12.5" stroke="#ffffff" stroke-width="1.2" stroke-linecap="round" />
              <defs>
                <linearGradient id="logoBgGrad" x1="0" y1="0" x2="24" y2="24" gradientUnits="userSpaceOnUse">
                  <stop stop-color="#c5ff6d" />
                  <stop offset="1" stop-color="#4CAF50" />
                </linearGradient>
              </defs>
            </svg>
            <span class="fw-bold fs-5" style="color:#ffffff;letter-spacing:-0.02em;">Fresh<span style="color:#c5ff6d!important;">Farm</span></span>
          </a>

          <!-- Desktop Menu -->
          <nav class="d-none d-md-flex align-items-center gap-4" aria-label="Menu chính">
            <a href="#" @click.prevent="$emit('navigate', 'home')" title="Trang chủ"
              class="ff-nav-link" :class="{ active: activeNav === 'home' }">Trang chủ</a>
            <a href="#" @click.prevent="$emit('navigate', 'products')" title="Danh sách sản phẩm"
              class="ff-nav-link" :class="{ active: activeNav === 'products' }">Sản phẩm</a>
            <a href="#" @click.prevent="$emit('navigate', 'about')" title="Về chúng tôi"
              class="ff-nav-link" :class="{ active: activeNav === 'about' }">Về chúng tôi</a>
          </nav>

          <!-- Hotline -->
          <div class="d-none d-lg-flex align-items-center gap-2 small mx-2" style="color:#ffffff !important;">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="#c5ff6d" stroke-width="2" style="flex-shrink:0;">
              <path stroke-linecap="round" stroke-linejoin="round" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.94.725l.548 2.2a1 1 0 01-.321.988l-1.305.98a10.582 10.582 0 004.872 4.872l.98-1.305a1 1 0 01.988-.321l2.2.548a1 1 0 01.725.94V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
            </svg>
            <span class="fw-medium" style="color:#ffffff!important;font-size:0.9rem;">Hotline: <span style="color:#c5ff6d!important;font-weight:600;">0933.151.151</span></span>
          </div>

          <!-- Search & Icons -->
          <div class="d-flex align-items-center gap-3">
            <!-- Desktop Search -->
            <div class="d-none d-md-flex ff-search-group">
              <input v-model="localSearch" @keyup.enter="triggerSearch" @input="handleSearchInput" type="text" aria-label="Tìm kiếm sản phẩm" placeholder="Tìm kiếm nông sản..."
                class="ff-search-input" />
              <button @click="triggerSearch" class="ff-search-btn" aria-label="Tìm kiếm">
                <MagnifyingGlassIcon style="width:14px;height:14px;" aria-hidden="true" />
              </button>
            </div>

            <!-- User Dropdown -->
            <div class="position-relative">
              <button @click="toggleUserMenu" aria-label="Tài khoản của bạn"
                class="btn p-1 rounded-circle border-0 ff-navbar-icon-btn">
                <div v-if="isLoggedIn" class="d-flex align-items-center justify-content-center rounded-circle bg-white text-success fw-bold"
                  style="width:34px;height:34px;font-size:0.75rem;box-shadow: 0 0 0 2px rgba(255,255,255,0.45);">{{ userInitials }}</div>
                <UserIcon v-else style="width:24px;height:24px;color:#ffffff;" aria-hidden="true" />
              </button>

              <!-- Dropdown -->
              <div v-if="showUserMenu" class="position-absolute end-0 bg-white border rounded-xl shadow-sm py-1" style="top:calc(100% + 8px);width:210px;z-index:1050;border-color:#f3f4f6;">
                <template v-if="isLoggedIn">
                  <div class="px-3 py-2 border-bottom" style="background:#f9fafb50;">
                    <p class="fw-semibold small text-dark truncate mb-0">{{ userName }}</p>
                    <p v-if="isAdmin" class="text-success fw-bold mb-0" style="font-size:0.6rem;letter-spacing:0.08em;">QUẢN TRỊ VIÊN</p>
                    <p v-else class="text-muted mb-0" style="font-size:0.65rem;">{{ userInfo?.email || '' }}</p>
                  </div>

                  <button v-if="isAdmin" @click="navigateAndClose('dashboard')"
                    class="btn btn-link w-100 text-start text-success fw-bold text-decoration-none d-flex align-items-center gap-2 px-3 py-2 small">
                    <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z" /></svg>
                    Vào trang quản trị
                  </button>
                  <button v-if="!isAdmin" @click="navigateAndClose('profile')"
                    class="btn btn-link w-100 text-start text-dark text-decoration-none d-flex align-items-center gap-2 px-3 py-2 small">
                    <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" /></svg>
                    Quản lý tài khoản
                  </button>
                  <button v-if="!isAdmin" @click="navigateAndClose('orderHistory')"
                    class="btn btn-link w-100 text-start text-dark text-decoration-none d-flex align-items-center gap-2 px-3 py-2 small">
                    <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" /></svg>
                    Quản lý đơn hàng
                  </button>
                  <hr class="my-1" />
                  <button @click="handleLogout" class="btn btn-link w-100 text-start text-danger text-decoration-none d-flex align-items-center gap-2 px-3 py-2 small">
                    <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" /></svg>
                    Đăng xuất
                  </button>
                </template>

                <template v-else>
                  <button @click="navigateAndClose('login')" class="btn btn-link w-100 text-start text-dark text-decoration-none d-flex align-items-center gap-2 px-3 py-2 small">
                    <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1" /></svg>
                    Đăng nhập
                  </button>
                  <button @click="navigateAndClose('register')" class="btn btn-link w-100 text-start text-dark text-decoration-none d-flex align-items-center gap-2 px-3 py-2 small">
                    <svg width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" /></svg>
                    Đăng ký
                  </button>
                </template>
              </div>

              <!-- Overlay to close -->
              <div v-if="showUserMenu" @click="showUserMenu = false" class="position-fixed top-0 start-0 w-100 h-100" style="z-index:1040;"></div>
            </div>

            <!-- Cart -->
            <button v-if="!isAdmin" @click="$emit('navigate', 'cart')" aria-label="Giỏ hàng"
              class="btn btn-link text-decoration-none p-1 position-relative ff-navbar-icon-btn">
              <ShoppingCartIcon style="width:24px;height:24px;color:#ffffff;" aria-hidden="true" />
              <span v-if="cartCount > 0"
                class="position-absolute top-0 end-0 d-flex align-items-center justify-content-center rounded-circle bg-danger text-white fw-bold"
                style="width:18px;height:18px;font-size:0.6rem;margin-top:-2px;margin-right:-2px;box-shadow: 0 0 0 2px #2E7D32;">
                {{ cartCount }}
              </span>
            </button>

            <!-- Mobile Search Toggle -->
            <button @click="showMobileSearch = !showMobileSearch" aria-label="Tìm kiếm di động" class="btn btn-link d-md-none p-1 text-decoration-none ff-navbar-icon-btn">
              <MagnifyingGlassIcon style="width:24px;height:24px;color:#ffffff;" aria-hidden="true" />
            </button>

            <!-- Mobile menu toggle -->
            <button @click="showMobileMenu = true" aria-label="Mở menu" class="btn btn-link d-md-none p-1 text-decoration-none ff-navbar-icon-btn">
              <Bars3Icon style="width:24px;height:24px;color:#ffffff;" aria-hidden="true" />
            </button>
          </div>
        </div>
      </div>
      <!-- Mobile Search Slide Down Panel -->
      <div v-if="showMobileSearch" class="d-md-none px-3 py-2 border-top" style="background:#1b5e20 !important; border-top-color: rgba(255, 255, 255, 0.1) !important;">
        <div class="ff-search-group w-100">
          <input v-model="localSearch" @keyup.enter="triggerSearch" @input="handleSearchInput" type="text" aria-label="Tìm kiếm sản phẩm di động" placeholder="Tìm kiếm nông sản..."
            class="ff-search-input" />
          <button @click="triggerSearch" class="ff-search-btn" aria-label="Tìm kiếm di động">
            <MagnifyingGlassIcon style="width:14px;height:14px;" aria-hidden="true" />
          </button>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="flex-grow-1 position-relative">
      <slot></slot>
    </main>

    <!-- Footer -->
    <footer class="bg-white border-top pt-5 pb-4" aria-label="Chân trang">
      <div class="container-xl px-3 px-sm-4">
        <div class="row g-4 g-md-5 mb-4">
          <div class="col-12 col-md-4">
            <div class="d-flex align-items-center gap-2 mb-3">
              <!-- Fresh Sprout SVG Icon -->
              <svg width="28" height="28" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style="flex-shrink:0;">
                <rect width="24" height="24" rx="7" fill="url(#logoBgGradFooter)" />
                <path d="M12 5C12 5 15 8 15 11.5C15 15 12 18 12 18C12 18 9 15 9 11.5C9 8 12 5 12 5Z" fill="#ffffff" />
                <path d="M12 8V15" stroke="#2E7D32" stroke-width="0.8" stroke-linecap="round" opacity="0.3" />
                <path d="M13 10.5C13 10.5 15.5 10.5 16.5 12.5" stroke="#ffffff" stroke-width="1.2" stroke-linecap="round" />
                <defs>
                  <linearGradient id="logoBgGradFooter" x1="0" y1="0" x2="24" y2="24" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#c5ff6d" />
                    <stop offset="1" stop-color="#2E7D32" />
                  </linearGradient>
                </defs>
              </svg>
              <span class="fw-bold fs-6" style="color:#2E7D32;">Fresh<span class="text-success" style="color:#4CAF50!important;">Farm</span></span>
            </div>
            <p class="text-muted small lh-lg">
              Chúng tôi cam kết mang đến những sản phẩm nông nghiệp sạch, an toàn và chất lượng cao nhất từ nông trại đến bàn ăn của gia đình bạn.
            </p>
          </div>
          <div class="col-6 col-md-2">
            <h3 class="fw-bold small text-dark mb-3">Về chúng tôi</h3>
            <ul class="list-unstyled small text-muted d-flex flex-column gap-2">
              <li><a href="#" class="text-muted text-decoration-none hover-success">Câu chuyện FreshFarm</a></li>
              <li><a href="#" class="text-muted text-decoration-none">Chứng nhận chất lượng</a></li>
              <li><a href="#" class="text-muted text-decoration-none">Hệ thống cửa hàng</a></li>
              <li><a href="#" class="text-muted text-decoration-none">Tuyển dụng</a></li>
            </ul>
          </div>
          <div class="col-6 col-md-3">
            <h3 class="fw-bold small text-dark mb-3">Hỗ trợ khách hàng</h3>
            <ul class="list-unstyled small text-muted d-flex flex-column gap-2">
              <li><a href="#" class="text-muted text-decoration-none">Chính sách giao hàng</a></li>
              <li><a href="#" class="text-muted text-decoration-none">Chính sách đổi trả</a></li>
              <li><a href="#" class="text-muted text-decoration-none">Hướng dẫn mua hàng</a></li>
              <li><a href="#" class="text-muted text-decoration-none">Câu hỏi thường gặp</a></li>
            </ul>
          </div>
          <div class="col-12 col-md-3">
            <h3 class="fw-bold small text-dark mb-3">Liên hệ</h3>
            <address class="not-italic small text-muted d-flex flex-column gap-2">
              <div class="d-flex gap-2"><span class="text-success">📍</span><span>123 Đường Nông Trại, Quận 1, TP. HCM</span></div>
              <div class="d-flex gap-2"><span class="text-success">📞</span><span>1900 1234 (Miễn phí)</span></div>
              <div class="d-flex gap-2"><span class="text-success">✉️</span><a href="mailto:hello@freshfarm.vn" class="text-muted text-decoration-none">hello@freshfarm.vn</a></div>
            </address>
          </div>
        </div>

        <div class="border-top pt-4 d-flex flex-column flex-md-row justify-content-between align-items-center gap-3">
          <p class="text-muted small mb-0">© 2026 FreshFarm. All rights reserved.</p>
          <div class="d-flex gap-2">
            <a href="#" aria-label="Facebook của FreshFarm" class="d-flex align-items-center justify-content-center rounded-circle bg-light text-muted text-decoration-none" style="width:32px;height:32px;transition:all 0.2s;">FB</a>
            <a href="#" aria-label="Instagram của FreshFarm" class="d-flex align-items-center justify-content-center rounded-circle bg-light text-muted text-decoration-none" style="width:32px;height:32px;">IG</a>
            <a href="#" aria-label="YouTube của FreshFarm" class="d-flex align-items-center justify-content-center rounded-circle bg-light text-muted text-decoration-none" style="width:32px;height:32px;">YT</a>
          </div>
        </div>
      </div>
    </footer>
  </div>
</template>
