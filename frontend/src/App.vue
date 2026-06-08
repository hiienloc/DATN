<template>
  <!-- Màn hình chặn truy cập trên điện thoại/máy tính bảng (Màn hình chỉ hỗ trợ laptop/desktop) -->
  <div v-if="isMobile" class="mobile-block-overlay">
    <div class="mobile-block-card">
      <svg class="laptop-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 17.25v1.007a3 3 0 0 1-.879 2.122L7.5 21h9l-.621-.621A3 3 0 0 1 15 18.257V17.25m6-12V15a2.25 2.25 0 0 1-2.25 2.25H5.25A2.25 2.25 0 0 1 3 15V5.25m18 0A2.25 2.25 0 0 0 18.75 3H5.25A2.25 2.25 0 0 0 3 5.25m18 0V12a2.25 2.25 0 0 1-2.25 2.25H5.25A2.25 2.25 0 0 1 3 12V5.25" />
      </svg>
      <h1>HỆ THỐNG CHỈ HỖ TRỢ TRÊN MÁY TÍNH</h1>
      <p>Để đảm bảo giao diện hiển thị chính xác và trải nghiệm quản lý kho, dự báo AI được tối ưu nhất, vui lòng truy cập trang web bằng máy tính xách tay (Laptop) hoặc máy tính để bàn (Desktop).</p>
      <div class="device-badge">
        <span>Kích thước màn hình khuyên dùng: ≥ 1024px</span>
      </div>
    </div>
  </div>

  <!-- Giao diện ứng dụng chính trên Laptop/Desktop -->
  <div v-else class="d-flex vh-100 bg-light font-sans w-100">
    <!-- Customer Pages Layout -->
    <div v-if="['home', 'products', 'cart', 'about', 'productDetail', 'orderHistory', 'profile'].includes(activeNav)" class="w-100 h-100 overflow-y-auto">
      <CustomerLayout :activeNav="activeNav" @navigate="handleNavigate" @search="handleSearch" :searchQuery="searchQuery">
        <HomeView v-if="activeNav === 'home'" @navigate="handleNavigate" />
        <ProductView v-else-if="activeNav === 'products'" :searchQuery="searchQuery" @navigate="handleNavigate" @viewProduct="handleViewProduct" />
        <Cart v-else-if="activeNav === 'cart'" @navigate="handleNavigate" />
        <AboutView v-else-if="activeNav === 'about'" @navigate="handleNavigate" />
        <ProductDetailView v-else-if="activeNav === 'productDetail'" :productId="selectedProductId" @navigate="handleNavigate" @viewProduct="handleViewProduct" />
        <OrderHistoryView v-else-if="activeNav === 'orderHistory'" @navigate="handleNavigate" />
        <ProfileView v-else-if="activeNav === 'profile'" @navigate="handleNavigate" />
      </CustomerLayout>
    </div>

    <!-- Trang Đăng ký -->
    <div v-else-if="activeNav === 'register'" class="w-100 h-100 overflow-y-auto bg-white">
      <RegisterView @navigate="activeNav = $event" />
    </div>

    <!-- Trang Đăng nhập -->
    <div v-else-if="activeNav === 'login'" class="w-100 h-100 overflow-y-auto bg-white">
      <LoginView @navigate="activeNav = $event" />
    </div>

    <!-- Trang kết quả thanh toán -->
    <div v-else-if="activeNav === 'paymentResult'" class="w-100 h-100 overflow-y-auto bg-white">
      <PaymentResult :status="paymentStatus" :orderId="paymentOrderId" @navigate="activeNav = $event" />
    </div>

    <!-- Layout cho trang Admin -->
    <template v-else>
      <div v-if="adminSidebarOpen" class="ff-sidebar-overlay" @click="adminSidebarOpen = false"></div>
      <AppSidebar @nav-change="handleNavChange" :activeNav="activeNav" :isOpen="adminSidebarOpen" @close-sidebar="adminSidebarOpen = false" />
      <div class="ff-admin-main">
        <AppTopbar v-model:search="adminSearchQuery" @nav-change="handleNavChange" @toggle-sidebar="adminSidebarOpen = !adminSidebarOpen" />
        <main class="flex-grow-1 overflow-auto bg-light p-4">
          <DashboardView v-if="activeNav === 'dashboard'" @nav-change="handleNavChange" />
          <CategoryManagement v-if="activeNav === 'category'" />
          <ProductManagement v-if="activeNav === 'product'" :searchQuery="adminSearchQuery" @nav-change="handleNavChange" />
          <PackageManagement v-if="activeNav === 'combo'" :searchQuery="adminSearchQuery" />
          <CustomerManagement v-if="activeNav === 'customer'" :searchQuery="adminSearchQuery" />
          <OrderManagement v-if="activeNav === 'order'" :searchQuery="adminSearchQuery" />
          <StatsManagement v-if="activeNav === 'stats'" />
          <InventoryManagement v-if="activeNav === 'inventory'" :productId="selectedInventoryId" :filter="selectedInventoryFilter" />
          <AdminProfile v-if="activeNav === 'adminProfile'" />
          <ForecastManagement v-if="activeNav === 'ai'" />
        </main>
      </div>
    </template>
    
    <!-- Container thông báo nổi toàn cục -->
    <ToastContainer />
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue'
import { toast } from '@/utils/toast'
import AppSidebar from '@/components/layout/admin/AppSidebar.vue'
import AppTopbar from '@/components/layout/admin/AppTopbar.vue'
import CategoryManagement from '@/components/layout/admin/CategoryManagement.vue'
import ProductManagement from '@/components/layout/admin/ProductManagement.vue'
import PackageManagement from '@/components/layout/admin/PackageManagement.vue'
import CustomerManagement from '@/components/layout/admin/CustomerManagement.vue'
import OrderManagement from '@/components/layout/admin/OrderManagement.vue'
import StatsManagement from '@/components/layout/admin/StatsManagement.vue'
import InventoryManagement from '@/components/layout/admin/InventoryManagement.vue'
import AdminProfile from '@/components/layout/admin/AdminProfile.vue'
import ForecastManagement from '@/components/layout/admin/ForecastManagement.vue'
import DashboardView from '@/views/DashboardView.vue'
import HomeView from '@/components/layout/customer/HomeView.vue'
import Cart from '@/components/layout/customer/Cart.vue'
import ProductView from '@/components/layout/customer/ProductView.vue'
import CustomerLayout from '@/components/layout/customer/CustomerLayout.vue'
import AboutView from '@/components/layout/customer/AboutView.vue'
import ProductDetailView from '@/components/layout/customer/ProductDetailView.vue'
import OrderHistoryView from '@/components/layout/customer/OrderHistoryView.vue'
import ProfileView from '@/components/layout/customer/ProfileView.vue'
import RegisterView from '@/views/RegisterView.vue'
import LoginView from '@/views/LoginView.vue'
import ToastContainer from '@/components/common/ToastContainer.vue'
import PaymentResult from '@/components/layout/customer/PaymentResult.vue'

const activeNav = ref('home')
const isMobile = ref(false)

const customerPages = ['home', 'products', 'cart', 'about', 'productDetail', 'orderHistory', 'profile', 'register', 'login', 'paymentResult']

const checkDevice = () => {
  // Chặn tất cả màn hình nhỏ hơn 1024px (Mobile & Tablet)
  isMobile.value = window.innerWidth < 1024
}

watch(activeNav, (newVal) => {
  if (!customerPages.includes(newVal)) {
    const role = localStorage.getItem('role')
    if (role?.toLowerCase() !== 'admin') {
      toast.error('Bạn không có quyền truy cập trang quản trị hệ thống!')
      activeNav.value = 'home'
    }
  }
}, { immediate: true })

const selectedProductId = ref(1)
const selectedInventoryId = ref(null)
const selectedInventoryFilter = ref('all')
const adminSidebarOpen = ref(false)

// State cho kết quả thanh toán VNPay
const paymentStatus = ref('')
const paymentOrderId = ref('')
const searchQuery = ref('')
const adminSearchQuery = ref('')

onMounted(() => {
  checkDevice()
  window.addEventListener('resize', checkDevice)

  const path = window.location.pathname
  const params = new URLSearchParams(window.location.search)
  const orderId = params.get('orderId')
  
  if (path === '/payment-success') {
    paymentStatus.value = 'success'
    paymentOrderId.value = orderId || ''
    activeNav.value = 'paymentResult'
    window.history.replaceState({}, document.title, '/')
  } else if (path === '/payment-failed') {
    paymentStatus.value = 'failed'
    paymentOrderId.value = orderId || ''
    activeNav.value = 'paymentResult'
    window.history.replaceState({}, document.title, '/')
  }
})

onUnmounted(() => {
  window.removeEventListener('resize', checkDevice)
})

const handleSearch = (query) => {
  searchQuery.value = query
  activeNav.value = 'products'
}

const handleNavigate = (page) => {
  activeNav.value = page
  if (page !== 'products' && page !== 'productDetail') {
    searchQuery.value = ''
  }
}

const handleNavChange = (payload) => {
  adminSearchQuery.value = ''
  if (typeof payload === 'object') {
    activeNav.value = payload.page
    selectedInventoryId.value = payload.productId || null
    selectedInventoryFilter.value = payload.filter || 'all'
  } else {
    activeNav.value = payload
    selectedInventoryId.value = null
    selectedInventoryFilter.value = 'all'
  }
}

const handleViewProduct = (id) => {
  selectedProductId.value = id
  activeNav.value = 'productDetail'
}
</script>

<style scoped>
.mobile-block-overlay {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  width: 100vw;
  background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
  color: #f8fafc;
  font-family: 'Inter', system-ui, -apple-system, sans-serif;
  padding: 24px;
  box-sizing: border-box;
}

.mobile-block-card {
  text-align: center;
  max-width: 480px;
  padding: 40px 30px;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 24px;
  backdrop-filter: blur(16px);
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
  animation: fadeIn 0.6s ease-out;
}

.laptop-icon {
  width: 80px;
  height: 80px;
  color: #10b981;
  margin: 0 auto 24px;
  animation: float 3s ease-in-out infinite;
}

h1 {
  font-size: 1.4rem;
  font-weight: 700;
  letter-spacing: 0.05em;
  margin-bottom: 16px;
  line-height: 1.4;
  background: linear-gradient(to right, #34d399, #059669);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

p {
  font-size: 0.92rem;
  line-height: 1.6;
  color: #94a3b8;
  margin-bottom: 30px;
}

.device-badge {
  display: inline-block;
  padding: 8px 16px;
  background: rgba(16, 185, 129, 0.08);
  border: 1px solid rgba(16, 185, 129, 0.15);
  border-radius: 12px;
  color: #34d399;
  font-size: 0.85rem;
  font-weight: 500;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes float {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-10px);
  }
}
</style>