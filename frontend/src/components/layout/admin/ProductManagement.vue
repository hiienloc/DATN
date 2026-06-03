<template>
  <div class="p-4 min-vh-100" style="background:var(--ff-bg-admin); ">
    <!-- Header -->
    <div class="d-flex align-items-center justify-content-between mb-4">
      <div>
        <h1 class="fs-5 fw-bold text-dark mb-0">Quản lý sản phẩm</h1>
        <p class="small text-muted mt-1 mb-0">Tổng cộng {{ filteredProducts.length }} sản phẩm</p>
      </div>
      <button @click="openAdd" class="btn btn-success rounded-xl fw-semibold d-flex align-items-center gap-2">
        <PlusIcon style="width:16px;height:16px;" /> Thêm sản phẩm
      </button>
    </div>
    <!-- Table -->
    <div class="bg-white rounded-2 border shadow-sm overflow-hidden" style="border-color:#f3f4f6;">
      <table class="table table-hover ff-table mb-0">
        <thead>
          <tr>
            <th style="width:60px;">STT</th><th>Mã SP</th><th>Tên sản phẩm</th>
            <th>Đơn vị</th><th>Danh mục</th>
            <th>Trạng thái</th>
            <th class="text-center" style="width:120px;">Thao tác</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="loading"><td colspan="7" class="text-center py-5 text-muted">Đang tải dữ liệu...</td></tr>
          <tr v-else-if="filteredProducts.length === 0"><td colspan="7" class="text-center py-5 text-muted">Không có sản phẩm nào</td></tr>
          <tr v-for="(product, index) in paginatedProducts" :key="product.productId">
            <td class="text-muted fw-medium">{{ (currentPage - 1) * itemsPerPage + index + 1 }}</td>
            <td class="fw-semibold text-dark">{{ product.productCode }}</td>
            <td class="fw-semibold text-dark">{{ product.productName }}</td>
            <td class="text-muted">{{ product.unit }}</td>
            <td><span class="badge rounded-pill fw-medium px-3 py-2" style="background:#ebf2ee;color:#4e7c66;font-size:0.72rem;">{{ product.categoryName || getCategoryName(product.categoryId) }}</span></td>
            <td>
              <span class="badge rounded-pill px-3 py-2 fw-medium" :style="product.isActive ? 'background:#ebf2ee;color:#4e7c66;font-size:0.72rem;' : 'background:#f0f0f0;color:#6c757d;font-size:0.72rem;'">
                {{ product.isActive ? 'Đang hoạt động' : 'Tạm ẩn' }}
              </span>
            </td>
            <td>
              <div class="d-flex align-items-center justify-content-center gap-1">
                <button @click="emit('nav-change', { page: 'inventory', productId: product.productId })" class="btn btn-sm btn-link text-success p-1" title="Tồn kho"><ArchiveBoxArrowDownIcon style="width:16px;height:16px;" /></button>
                <button @click="openEdit(product)" class="btn btn-sm btn-link text-primary p-1" title="Sửa"><PencilSquareIcon style="width:16px;height:16px;" /></button>
                <button 
                  @click="toggleActive(product)" 
                  class="btn btn-sm btn-link p-1"
                  :class="product.isActive ? 'text-warning' : 'text-success'"
                  :title="product.isActive ? 'Khóa' : 'Mở khóa'"
                >
                  <component :is="product.isActive ? LockClosedIcon : LockOpenIcon" style="width:16px;height:16px;" />
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>

      <!-- Pagination Footer (Bootstrap 5) -->
      <div v-if="totalPages > 1" class="d-flex flex-column flex-md-row align-items-center justify-content-between bg-white p-3 border-top border-light gap-3">
        <div class="small text-muted">
          Hiển thị <b>{{ (currentPage - 1) * itemsPerPage + 1 }}</b> - <b>{{ Math.min(currentPage * itemsPerPage, filteredProducts.length) }}</b> trên tổng số <b>{{ filteredProducts.length }}</b> sản phẩm
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
    <!-- Modal Thêm / Sửa -->
    <Teleport to="body">
      <div v-if="showModal" class="ff-modal-overlay" @click="closeModal">
        <div class="ff-modal-box" @click.stop style="max-width:32rem;">
          <div class="p-4 border-bottom d-flex align-items-center justify-content-between bg-light">
            <h2 class="fw-bold small mb-0">{{ isEditing ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới' }}</h2>
            <button @click="closeModal" class="btn btn-sm btn-outline-secondary rounded-xl"><XMarkIcon style="width:14px;height:14px;" /></button>
          </div>
          <div class="p-4">
            <div class="mb-3">
              <label class="form-label small fw-semibold">Mã sản phẩm <span class="text-danger">*</span></label>
              <input v-model="form.productCode" type="text" placeholder="VD: SP001" class="form-control rounded-xl" />
            </div>
            <div class="mb-3">
              <label class="form-label small fw-semibold">Tên sản phẩm <span class="text-danger">*</span></label>
              <input v-model="form.productName" type="text" placeholder="VD: Cà rốt hữu cơ Đà Lạt" class="form-control rounded-xl" />
            </div>
            <div class="row g-3 mb-3">
              <div class="col-6">
                <label class="form-label small fw-semibold">Danh mục <span class="text-danger">*</span></label>
                <select v-model="form.categoryId" class="form-select rounded-xl">
                  <option :value="0" disabled>Chọn danh mục</option>
                  <option v-for="cat in categoryOptions" :key="cat.categoryId" :value="cat.categoryId">{{ cat.categoryName }}</option>
                </select>
              </div>
              <div class="col-6">
                <label class="form-label small fw-semibold">Đơn vị tính <span class="text-danger">*</span></label>
                <input v-model="form.unit" type="text" placeholder="VD: kg, bó, hộp" class="form-control rounded-xl" />
              </div>
            </div>
            <!-- Trạng thái -->
            <div class="mb-3">
              <label class="form-label small fw-semibold text-muted">Trạng thái</label>
              <div class="d-flex gap-4">
                <label class="d-flex align-items-center gap-2" style="cursor: pointer;">
                  <input type="radio" v-model="form.isActive" :value="true" class="form-check-input" />
                  <span class="small text-dark">Đang hoạt động</span>
                </label>
                <label class="d-flex align-items-center gap-2" style="cursor: pointer;">
                  <input type="radio" v-model="form.isActive" :value="false" class="form-check-input" />
                  <span class="small text-dark">Tạm ẩn</span>
                </label>
              </div>
            </div>
          </div>
          <div class="p-4 border-top d-flex gap-3">
            <button @click="closeModal" class="btn btn-light flex-grow-1 rounded-xl fw-semibold">Hủy</button>
            <button @click="saveProduct" :disabled="saving" class="btn btn-success flex-grow-1 rounded-xl fw-semibold">
              <span v-if="saving" class="spinner-border spinner-border-sm me-1"></span>
              {{ saving ? 'Đang lưu...' : 'Lưu' }}
            </button>
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
import {
  PlusIcon,
  PencilSquareIcon,
  XMarkIcon,
  ArchiveBoxArrowDownIcon,
  ChevronLeftIcon,
  ChevronRightIcon,
  LockClosedIcon,
  LockOpenIcon
} from '@heroicons/vue/24/outline'

const props = defineProps({
  searchQuery: { type: String, default: '' }
})

// ── State ──────────────────────────────────────────────────────────────────
const emit = defineEmits(['nav-change'])

const showModal = ref(false)
const isEditing = ref(false)
const loading = ref(false)
const saving = ref(false)

const categoryOptions = ref([])
const products = ref([])

// Pagination state
const currentPage = ref(1)
const itemsPerPage = ref(10)

const emptyForm = () => ({ productId: 0, productCode: '', productName: '', unit: 'kg', categoryId: 0, isActive: true })
const form = ref(emptyForm())

// ── Load Data từ Backend ────────────────────────────────────────────────────
const fetchProducts = async () => {
  loading.value = true
  try {
    const response = await apiClient.get('/Product')
    products.value = response.data.data || response.data
    // Tự động hạ trang hiện tại nếu bị vượt quá giới hạn (ví dụ sau khi xóa bớt)
    if (currentPage.value > totalPages.value) {
      currentPage.value = Math.max(1, totalPages.value)
    }
  } catch (error) {
    console.error("Lỗi khi tải sản phẩm:", error)
    toast.error("Không thể tải dữ liệu sản phẩm từ máy chủ!")
  } finally {
    loading.value = false
  }
}

const fetchCategories = async () => {
  try {
    const response = await apiClient.get('/Category')
    categoryOptions.value = response.data.data || response.data
  } catch (error) {
    console.error("Lỗi khi tải danh mục:", error)
  }
}

onMounted(() => {
  fetchProducts()
  fetchCategories()
})

// ── Helpers ────────────────────────────────────────────────────────────────
const removeAccents = (str) => {
  return str ? str.normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd').replace(/Đ/g, 'D') : ''
}

// ── Computed ───────────────────────────────────────────────────────────────
const filteredProducts = computed(() => {
  const query = removeAccents(props.searchQuery).toLowerCase().trim()
  if (!query) return products.value
  return products.value.filter(p => {
    const codeMatch = p.productCode ? removeAccents(p.productCode).toLowerCase().includes(query) : false
    const nameMatch = p.productName ? removeAccents(p.productName).toLowerCase().includes(query) : false
    const catMatch = p.categoryId ? removeAccents(getCategoryName(p.categoryId)).toLowerCase().includes(query) : false
    return codeMatch || nameMatch || catMatch
  })
})

watch(() => props.searchQuery, () => {
  currentPage.value = 1
})

const totalPages = computed(() => Math.ceil(filteredProducts.value.length / itemsPerPage.value))

const paginatedProducts = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  return filteredProducts.value.slice(start, start + itemsPerPage.value)
})

// ── Helpers ────────────────────────────────────────────────────────────────

const getCategoryName = (categoryId) => {
  const cat = categoryOptions.value.find(c => c.categoryId === categoryId)
  return cat ? cat.categoryName : '—'
}

/**
 * Kiểm tra toàn bộ form sản phẩm
 * @returns {boolean} true nếu tất cả dữ liệu hợp lệ
 */
const validateForm = () => {
  // Định nghĩa các field bắt buộc
  const requiredFields = {
    productCode: 'Mã sản phẩm',
    productName: 'Tên sản phẩm',
    unit: 'Đơn vị',
  }
  
  // Kiểm tra từng field text
  for (const [field, fieldName] of Object.entries(requiredFields)) {
    if (!form.value[field]?.trim()) {
      toast.warning('Vui lòng nhập đầy đủ thông tin!')
      return false
    }
  }
  
  // Kiểm tra danh mục (bắt buộc chọn)
  if (!form.value.categoryId) {
    toast.warning('Vui lòng chọn danh mục!')
    return false
  }
  
  return true
}

/**
 * Trích xuất error message từ response API
 * @param {Error} error - Error object từ API
 * @returns {string} Error message đã format
 */
const getErrorMessage = (error) => {
  // Ưu tiên: message từ API → title → error message
  return error.response?.data?.message || 
         error.response?.data?.title || 
         error.message
}

// ── Methods ────────────────────────────────────────────────────────────────

function openAdd() {
  isEditing.value = false
  form.value = emptyForm()
  showModal.value = true
}

function openEdit(product) {
  isEditing.value = true
  form.value = { ...product, categoryId: product.categoryId || 0, isActive: product.isActive !== false }
  showModal.value = true
}

function closeModal() {
  showModal.value = false
  form.value = emptyForm()
}


async function saveProduct() {
  // STEP 1: Kiểm tra validation
  if (!validateForm()) return

  saving.value = true
  try {
    // STEP 2: Chuẩn bị dữ liệu gửi lên
    const { productId, ...payload } = form.value  // Tách productId ra, phần còn lại là payload
    
    // STEP 3: Chọn endpoint & method dựa trên chế độ (thêm hay sửa)
    const isAddNew = !isEditing.value
    const endpoint = isAddNew ? '/Product/add' : '/Product/update'
    const method = isAddNew ? 'post' : 'put'
    
    // STEP 4: Thêm productId vào payload nếu chế độ sửa
    if (isEditing.value) {
      payload.productId = productId
    }
    
    // STEP 5: Gửi API
    await apiClient[method](endpoint, payload)
    
    // STEP 6: Reload danh sách và đóng modal
    await fetchProducts()
    closeModal()
    toast.success(isEditing.value ? 'Cập nhật sản phẩm thành công!' : 'Thêm sản phẩm thành công!')
  } catch (error) {
    // Xử lý lỗi
    toast.error("Lỗi khi lưu dữ liệu: " + getErrorMessage(error))
  } finally {
    saving.value = false
  }
}

async function toggleActive(product) {
  try {
    const payload = {
      productId: product.productId,
      productCode: product.productCode,
      productName: product.productName,
      unit: product.unit,
      categoryId: product.categoryId,
      isActive: !product.isActive
    }
    await apiClient.put('/Product/update', payload)
    await fetchProducts()
    toast.success(product.isActive ? 'Khóa sản phẩm thành công!' : 'Mở khóa sản phẩm thành công!')
  } catch (error) {
    toast.error('Lỗi khi cập nhật sản phẩm: ' + getErrorMessage(error))
  }
}

</script>
