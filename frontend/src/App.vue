<template>
  <div class="d-flex vh-100 bg-light font-sans w-100">
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
import { ref, onMounted, watch } from 'vue'
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

const customerPages = ['home', 'products', 'cart', 'about', 'productDetail', 'orderHistory', 'profile', 'register', 'login', 'paymentResult']

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