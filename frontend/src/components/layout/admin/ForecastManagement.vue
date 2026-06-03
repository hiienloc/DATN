<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import ForecastChart from '@/components/common/ForecastChart.vue'
import apiClient from '@/api/axios'
import {
  LightBulbIcon,
  ArrowPathIcon,
  ChartBarIcon,
  CubeIcon,
  CalendarDaysIcon,
  SparklesIcon,
  ExclamationTriangleIcon,
  CheckCircleIcon,
  ArrowTrendingUpIcon,
  ArchiveBoxIcon,
  ClockIcon,
  InformationCircleIcon
} from '@heroicons/vue/24/outline'
 
// ── Constants ──────────────────────────────────────────────────────────────
const HISTORY_PAGE_SIZE = 10
 
// ── State ──────────────────────────────────────────────────────────────────
const products = ref([])
const selectedProductId = ref(null)
const loading = ref(false)
const loadingProducts = ref(false)
const loadingActual = ref(false)   // ✅ FIX: tách state loading cho chart thực tế
const loadingHistory = ref(false)
const forecastResult = ref(null)
const actualHistory = ref({ salesHistory: [], exportHistory: [] })
const errorMsg = ref('')
const forecastHistory = ref([])
 
// ── Fetch danh sách sản phẩm ──────────────────────────────────────────────
const fetchProducts = async () => {
  loadingProducts.value = true
  try {
    const res = await apiClient.get('/ForecastResult/qualified-products')
    products.value = res.data.data || res.data || []
  } catch (e) {
    console.error('Lỗi tải danh sách sản phẩm:', e)
  } finally {
    loadingProducts.value = false
  }
}
 
// ── Validate input ─────────────────────────────────────────────────────────
const validateForecastInput = () => {
  if (!selectedProductId.value) {
    errorMsg.value = 'Vui lòng chọn sản phẩm để dự báo.'
    return false
  }
  return true
}
 
// ── Xử lý lỗi API ─────────────────────────────────────────────────────────
const handleForecastError = (e) => {
  console.error('Lỗi dự báo:', e)
  const data = e.response?.data
  if (typeof data === 'string') {
    errorMsg.value = data
  } else if (data?.message) {
    errorMsg.value = data.message
  } else {
    errorMsg.value = 'Không thể tạo dự báo. Vui lòng kiểm tra dữ liệu lịch sử của sản phẩm này.'
  }
}
 
// ── Tạo dự báo ────────────────────────────────────────────────────────────
// ✅ FIX: Bỏ forecastDate — backend tự lấy DateTime.Today, không cần truyền
const generateForecast = async () => {
  if (!validateForecastInput()) return
 
  errorMsg.value = ''
  loading.value = true
  forecastResult.value = null
 
  try {
    const res = await apiClient.post('/ForecastResult/generate', null, {
      params: {
        productId: selectedProductId.value
      }
    })
 
    forecastResult.value = res.data.data || res.data
    await fetchActualHistory(selectedProductId.value)
    fetchHistory()
  } catch (e) {
    handleForecastError(e)
  } finally {
    loading.value = false
  }
}
 
// ── Lấy lịch sử thực tế cho biểu đồ ──────────────────────────────────────
const fetchActualHistory = async (productId) => {
  loadingActual.value = true
  try {
    const res = await apiClient.get('/ForecastResult/actual-history', {
      params: { productId }
    })
    actualHistory.value = res.data.data || res.data || { salesHistory: [], exportHistory: [] }
  } catch (e) {
    actualHistory.value = { salesHistory: [], exportHistory: [] }
  } finally {
    loadingActual.value = false
  }
}
 
// ── Computed cho biểu đồ ──────────────────────────────────────────────────
const chartActualSales = computed(() => actualHistory.value?.salesHistory || [])
const chartActualExport = computed(() => actualHistory.value?.exportHistory || [])
const chartForecastData = computed(() => {
  if (!forecastResult.value) return []
  const dateObj = new Date(forecastResult.value.forecastDate)
  const formattedDate = `${dateObj.getDate()}/${dateObj.getMonth() + 1}`
  return [{ date: formattedDate, value: Number(forecastResult.value.predictQuantity) || 0 }]
})
const chartUnit = computed(() => forecastResult.value?.unit || 'đơn vị')
 
// ── Lịch sử dự báo ────────────────────────────────────────────────────────
const fetchHistory = async () => {
  loadingHistory.value = true
  try {
    const res = await apiClient.get('/ForecastResult')
    const raw = res.data.data || res.data || []
    // ✅ FIX: dùng constant thay vì hardcode số
    forecastHistory.value = Array.isArray(raw) ? raw.slice(0, HISTORY_PAGE_SIZE) : []
  } catch (e) {
    console.error('Lỗi tải lịch sử dự báo:', e)
  } finally {
    loadingHistory.value = false
  }
}
 
// ── Helpers ───────────────────────────────────────────────────────────────
const selectedProductName = computed(() => {
  const p = products.value.find(p => p.productId == selectedProductId.value)
  return p ? p.productName : '—'
})
 
const formatNumber = (n) => {
  if (n == null) return '—'
  return new Intl.NumberFormat('vi-VN', { maximumFractionDigits: 1 }).format(n)
}
 
const formatDate = (d) => {
  if (!d) return '—'
  return new Date(d).toLocaleDateString('vi-VN', { timeZone: 'Asia/Ho_Chi_Minh' })
}
 
// ── Watch ─────────────────────────────────────────────────────────────────
watch(selectedProductId, async (newId) => {
  errorMsg.value = ''
  forecastResult.value = null
  if (newId) {
    await fetchActualHistory(newId)
  } else {
    actualHistory.value = { salesHistory: [], exportHistory: [] }
  }
})
 
// ── Init ──────────────────────────────────────────────────────────────────
onMounted(() => {
  fetchProducts()
  fetchHistory()
})
</script>
 
<template>
  <div class="p-4 min-vh-100" style="background: var(--ff-bg-admin); ">
 
    <!-- Header -->
    <div class="d-flex align-items-center gap-3 mb-4">
      <div
        class="bg-primary bg-opacity-10 text-primary rounded-3 p-2 d-flex align-items-center justify-content-center shadow-sm"
        style="width: 45px; height: 45px;"
      >
        <SparklesIcon style="width: 24px; height: 24px;" />
      </div>
      <div>
        <h1 class="fs-4 fw-bold text-dark mb-0">Dự báo nhu cầu tiêu thụ</h1>
        <p class="small text-muted mb-0">
          Dự báo tổng nhu cầu tiêu thụ (3–7 ngày) bằng Trí tuệ nhân tạo (Gemini AI)
        </p>
      </div>
    </div>
 
    <!-- Input Form Card -->
    <div class="card border-0 shadow-sm rounded-3 mb-4 overflow-hidden">
      <div class="card-header bg-white border-bottom py-3">
        <h5 class="card-title fw-bold text-dark small mb-0 d-flex align-items-center gap-2">
          <LightBulbIcon class="text-success" style="width: 18px; height: 18px;" />
          Thiết lập dự báo
        </h5>
        <p class="text-muted mb-0" style="font-size: 0.8rem; margin-top: 2px;">
          Chọn sản phẩm để phân tích xu hướng và dự báo nhu cầu
        </p>
      </div>
      <div class="card-body p-4">
        <div class="row g-3 align-items-end">
          <!-- Product Select -->
          <div class="col-12 col-md-8">
            <label class="form-label small fw-semibold text-muted mb-2">
              <CubeIcon class="me-1 text-secondary" style="width: 16px; height: 16px; vertical-align: text-bottom;" />
              Sản phẩm
              <span class="text-muted fw-normal ms-1">(chỉ hiển thị sản phẩm đã có đơn hàng hoàn thành)</span>
            </label>
            <select
              v-model="selectedProductId"
              class="form-select rounded-3"
              :disabled="loadingProducts"
            >
              <option :value="null" disabled>
                {{ loadingProducts ? 'Đang tải...' : '— Chọn sản phẩm —' }}
              </option>
              <option v-for="p in products" :key="p.productId" :value="p.productId">
                {{ p.productCode ? `[${p.productCode}] ` : '' }}{{ p.productName }}
              </option>
            </select>
          </div>
 
          <!-- Generate Button -->
          <div class="col-12 col-md-4">
            <button
              @click="generateForecast"
              :disabled="loading || !selectedProductId"
              class="btn btn-primary w-100 fw-bold rounded-3 d-flex align-items-center justify-content-center gap-2 py-2 shadow-sm"
              style="background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%); border: none;"
            >
              <ArrowPathIcon v-if="loading" style="width: 16px; height: 16px;" class="animate-spin" />
              <SparklesIcon v-else style="width: 16px; height: 16px;" />
              {{ loading ? 'Đang phân tích...' : 'Tạo dự báo' }}
            </button>
          </div>
        </div>
 
        <!-- Error Message -->
        <Transition
          enter-active-class="transition duration-200 ease-out"
          enter-from-class="opacity-0 -translate-y-2"
          enter-to-class="opacity-100 translate-y-0"
        >
          <div
            v-if="errorMsg"
            class="alert alert-danger d-flex align-items-center gap-2 mt-3 mb-0 py-2 px-3 rounded-3 small"
            role="alert"
          >
            <ExclamationTriangleIcon style="width: 16px; height: 16px;" />
            <div>{{ errorMsg }}</div>
          </div>
        </Transition>
      </div>
    </div>
 
    <!-- Biểu đồ thực tế (hiển thị khi đã chọn sản phẩm) -->
    <Transition
      enter-active-class="transition duration-500 ease-out"
      enter-from-class="opacity-0 translate-y-4"
      enter-to-class="opacity-100 translate-y-0"
    >
      <div v-if="selectedProductId" class="mb-4">
        <div class="card border-0 shadow-sm rounded-3">
          <div class="card-body p-4">
            <h5 class="fw-bold text-dark small mb-4 d-flex align-items-center gap-2">
              <ChartBarIcon class="text-primary" style="width: 18px; height: 18px;" />
              Biểu đồ thực tế & dự báo
            </h5>
            <div v-if="loadingActual" class="text-center py-5 text-muted small">
              <div class="spinner-border spinner-border-sm text-secondary me-2" role="status"></div>
              Đang tải dữ liệu thực tế...
            </div>
            <ForecastChart
              v-else
              :salesHistory="chartActualSales"
              :exportHistory="chartActualExport"
              :forecastData="chartForecastData"
              :unit="chartUnit"
            />
          </div>
        </div>
      </div>
    </Transition>
 
    <!-- Kết quả dự báo chi tiết -->
    <Transition
      enter-active-class="transition duration-500 ease-out"
      enter-from-class="opacity-0 translate-y-4"
      enter-to-class="opacity-100 translate-y-0"
    >
      <div v-if="forecastResult" class="mb-4">
 
        <!-- Result Header Banner -->
        <!-- ✅ FIX: Bỏ "Mã dự báo #ID" — thay bằng forecastType có nghĩa hơn -->
        <div
          class="card border-0 text-white shadow-sm rounded-3 mb-4 position-relative overflow-hidden"
          style="background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%) !important;"
        >
          <div
            class="card-body p-4 d-flex flex-column flex-md-row justify-content-between align-items-md-center position-relative"
            style="z-index: 2;"
          >
            <div>
              <div class="d-flex align-items-center gap-2 mb-2">
                <CheckCircleIcon style="width: 20px; height: 20px; color: #34d399;" />
                <span class="fw-bold small text-white-50 text-uppercase tracking-wider">
                  Kết quả dự báo thành công
                </span>
              </div>
              <h2 class="h3 fw-black mb-1 text-white">
                {{ forecastResult.productName || selectedProductName }}
              </h2>
              <p class="mb-0 text-white-50 small d-flex align-items-center gap-1">
                <CalendarDaysIcon style="width: 16px; height: 16px;" />
                Dự báo cho ngày: {{ formatDate(forecastResult.forecastDate) }}
              </p>
            </div>
            <div class="text-md-end mt-3 mt-md-0">
              <p class="small text-white-50 text-uppercase mb-1">Loại dự báo</p>
              <span
                class="badge rounded-pill px-3 py-2 fw-bold"
                style="background: rgba(255,255,255,0.2); font-size: 1rem;"
              >
                {{ forecastResult.forecastType || '—' }}
              </span>
            </div>
          </div>
        </div>
 
        <!-- Result Cards Grid -->
        <div class="row g-4 mb-4">
          <!-- Predicted Quantity -->
          <div class="col-12 col-md-6">
            <div class="card border-0 shadow-sm rounded-3 h-100">
              <div class="card-body p-4">
                <div class="d-flex align-items-center justify-content-between mb-3">
                  <span class="small fw-semibold text-muted text-uppercase tracking-wider">Nhu cầu dự báo</span>
                  <div
                    class="bg-primary bg-opacity-10 text-primary rounded-3 d-flex align-items-center justify-content-center"
                    style="width: 36px; height: 36px;"
                  >
                    <ArrowTrendingUpIcon style="width:18px;height:18px;" />
                  </div>
                </div>
                <p class="h2 fw-bold text-dark mb-1">{{ formatNumber(forecastResult.predictQuantity) }}</p>
                <p class="small text-muted mb-0">{{ forecastResult.unit || 'đơn vị' }}</p>
              </div>
            </div>
          </div>
 
          <!-- Suggest Restock -->
          <div class="col-12 col-md-6">
            <div class="card border-0 shadow-sm rounded-3 h-100">
              <div class="card-body p-4">
                <div class="d-flex align-items-center justify-content-between mb-3">
                  <span class="small fw-semibold text-muted text-uppercase tracking-wider">Đề xuất nhập thêm</span>
                  <div
                    class="bg-warning bg-opacity-10 text-warning rounded-3 d-flex align-items-center justify-content-center"
                    style="width: 36px; height: 36px;"
                  >
                    <ArchiveBoxIcon style="width:18px;height:18px;" />
                  </div>
                </div>
                <p
                  class="h2 fw-bold mb-1"
                  :class="forecastResult.suggestReStock > 0 ? 'text-warning' : 'text-success'"
                >
                  {{ formatNumber(forecastResult.suggestReStock) }}
                </p>
                <p
                  class="small fw-bold mb-0"
                  :class="forecastResult.suggestReStock > 0 ? 'text-warning' : 'text-success'"
                >
                  {{ forecastResult.suggestReStock > 0 ? '⚠ Cần nhập thêm hàng' : '✓ Đủ hàng tồn kho' }}
                </p>
              </div>
            </div>
          </div>
        </div>
 
        <!-- Detail Info Block -->
        <div class="card border-0 shadow-sm rounded-3 mb-4">
          <div class="card-body p-4">
            <h5 class="fw-bold text-dark small mb-4 d-flex align-items-center gap-2">
              <InformationCircleIcon class="text-primary" style="width: 18px; height: 18px;" />
              Chi tiết dự báo
            </h5>
            <div class="d-flex flex-column gap-2">
              <div class="d-flex justify-content-between align-items-center p-3 rounded-3 bg-light">
                <span class="small text-muted">Sản phẩm</span>
                <span class="fw-bold text-dark">{{ forecastResult.productName || selectedProductName }}</span>
              </div>
              <div class="d-flex justify-content-between align-items-center p-3 rounded-3 bg-light">
                <span class="small text-muted">Loại dự báo</span>
                <span class="fw-bold text-dark">{{ forecastResult.forecastType || '—' }}</span>
              </div>
              <div class="d-flex justify-content-between align-items-center p-3 rounded-3 bg-light">
                <span class="small text-muted">Ngày dự báo</span>
                <span class="fw-bold text-dark">{{ formatDate(forecastResult.forecastDate) }}</span>
              </div>
              <div class="d-flex justify-content-between align-items-center p-3 rounded-3 bg-light">
                <span class="small text-muted">Tồn kho hiện tại</span>
                <span class="fw-bold text-dark">
                  {{ formatNumber(forecastResult.currentStock) }} {{ forecastResult.unit || '' }}
                </span>
              </div>
              <div class="d-flex justify-content-between align-items-center p-3 rounded-3 bg-light">
                <span class="small text-muted">Nhu cầu dự báo</span>
                <span class="fw-bold text-primary">
                  {{ formatNumber(forecastResult.predictQuantity) }} {{ forecastResult.unit || '' }}
                </span>
              </div>
              <div
                class="d-flex justify-content-between align-items-center p-3 rounded-3"
                :class="forecastResult.suggestReStock > 0
                  ? 'bg-warning bg-opacity-10 text-warning'
                  : 'bg-success bg-opacity-10 text-success'"
              >
                <span class="small">Đề xuất nhập thêm</span>
                <span class="fw-bold">
                  {{ forecastResult.suggestReStock > 0
                    ? formatNumber(forecastResult.suggestReStock) + ' ' + (forecastResult.unit || '')
                    : '✓ Không cần nhập thêm' }}
                </span>
              </div>
              <div class="d-flex justify-content-between align-items-center p-3 rounded-3 bg-light">
                <span class="small text-muted">Thời gian tạo</span>
                <span class="small font-medium text-muted">{{ formatDate(forecastResult.generatedAt) }}</span>
              </div>
            </div>
          </div>
        </div>
 
      </div>
    </Transition>
 
    <!-- Forecast History Table -->
    <div class="card border-0 shadow-sm rounded-3 overflow-hidden">
      <div class="card-header bg-white border-bottom py-3 d-flex align-items-center justify-content-between">
        <h5 class="fw-bold text-dark small mb-0 d-flex align-items-center gap-2">
          <ClockIcon class="text-secondary" style="width: 18px; height: 18px;" />
          Lịch sử dự báo gần đây
        </h5>
        <button
          @click="fetchHistory"
          :disabled="loadingHistory"
          class="btn btn-link btn-sm p-0 text-decoration-none fw-semibold"
        >
          {{ loadingHistory ? 'Đang tải...' : 'Làm mới' }}
        </button>
      </div>
      <div class="table-responsive">
        <table class="table table-hover ff-table mb-0" style="font-size:0.9rem;">
          <thead class="table-light">
            <tr>
              <th class="px-4 py-3">Sản phẩm</th>
              <th class="px-4 py-3">Ngày dự báo</th>
              <th class="px-4 py-3 text-center">Loại dự báo</th>
              <th class="px-4 py-3 text-center">Nhu cầu dự báo</th>
              <th class="px-4 py-3 text-center">Đề xuất nhập</th>
              <th class="px-4 py-3">Thời gian tạo</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="loadingHistory">
              <td colspan="6" class="px-4 py-5 text-center text-muted">
                <div class="spinner-border spinner-border-sm text-secondary me-2" role="status"></div>
                Đang tải...
              </td>
            </tr>
            <tr v-else-if="forecastHistory.length === 0">
              <td colspan="6" class="px-4 py-5 text-center text-muted">
                Chưa có dữ liệu dự báo nào
              </td>
            </tr>
            <tr v-for="item in forecastHistory" :key="item.forecastId">
              <td class="px-4 py-3 fw-semibold text-dark">
                {{ item.productName || `SP #${item.productId}` }}
              </td>
              <td class="px-4 py-3 text-secondary">{{ formatDate(item.forecastDate) }}</td>
              <td class="px-4 py-3 text-center">
                <span class="badge rounded-pill bg-primary bg-opacity-10 text-primary px-2 py-1" style="font-size: 0.75rem;">
                  {{ item.forecastType || '—' }}
                </span>
              </td>
              <td class="px-4 py-3 text-center fw-bold text-primary">
                {{ formatNumber(item.predictQuantity) }} {{ item.unit || '' }}
              </td>
              <td class="px-4 py-3 text-center">
                <span
                  class="badge rounded-pill text-uppercase px-2 py-1"
                  :class="item.suggestReStock > 0
                    ? 'bg-warning-subtle text-warning border border-warning'
                    : 'bg-success-subtle text-success border border-success'"
                  style="font-size: 0.7rem;"
                >
                  {{ item.suggestReStock > 0
                    ? formatNumber(item.suggestReStock) + ' ' + (item.unit || '')
                    : '✓ Đủ' }}
                </span>
              </td>
              <td class="px-4 py-3 text-muted small">{{ formatDate(item.generatedAt) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
 
  </div>
</template>