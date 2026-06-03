<template>
  <div class="p-4 min-vh-100" style="background:var(--ff-bg-admin); ">

    <!-- Header -->
    <div class="d-flex align-items-center justify-content-between mb-4">
      <div>
        <h1 class="fs-5 fw-bold text-dark">Quản lý gói sản phẩm (Combo)</h1>
        <p class="small text-muted mt-1 mb-0">Tổng cộng {{ filteredPackages.length }} gói</p>
      </div>
      <button
        @click="openAdd"
        class="btn btn-success d-flex align-items-center gap-2 fw-semibold small rounded-3 shadow-sm"
      >
        <PlusIcon style="width:16px;height:16px;" />
        Thêm gói mới
      </button>
    </div>
    <!-- Table -->
    <div class="bg-white rounded-2 border shadow-sm overflow-hidden">
      <table class="table table-hover ff-table mb-0" style="font-size:0.9rem;">
        <thead>
          <tr>
            <th class="px-4 py-3" style="width:60px;">STT</th>
            <th class="px-4 py-3" style="width:60px;">Ảnh</th>
            <th class="px-4 py-3">Mã gói</th>
            <th class="px-4 py-3">Tên gói (Combo)</th>
            <th class="px-4 py-3">Mô tả</th>
            <th class="px-4 py-3">Giá gốc</th>
            <th class="px-4 py-3">Giá KM</th>
            <th class="px-4 py-3">Trạng thái</th>
            <th class="px-4 py-3 text-center" style="width:100px;">Thao tác</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="loading">
            <td colspan="9" class="text-center py-5 text-muted">Đang tải dữ liệu...</td>
          </tr>
          <tr v-else-if="filteredPackages.length === 0">
            <td colspan="9" class="text-center py-5 text-muted">Không có gói sản phẩm nào</td>
          </tr>
          <template v-for="(pkg, index) in paginatedPackages" :key="pkg.packageId">
            <tr
              style="cursor:pointer;"
              @click="toggleExpand(pkg)"
            >
            <td class="px-4 py-3 text-muted fw-medium">{{ (currentPage - 1) * itemsPerPage + index + 1 }}</td>
            <td class="px-4 py-3">
              <div class="rounded-2 border overflow-hidden d-flex align-items-center justify-content-center" style="width:48px;height:48px;background:#f3f4f6;">
                <img v-if="pkg.imageUrl" :src="getImageUrl(pkg.imageUrl)" alt="" style="width:100%;height:100%;object-fit:cover;" />
                <span v-else class="text-muted" style="font-size:10px;">Trống</span>
              </div>
            </td>
            <td class="px-4 py-3 fw-semibold text-dark">{{ pkg.packageCode }}</td>
            <td class="px-4 py-3 fw-semibold text-dark">{{ pkg.packageName }}</td>
            <td class="px-4 py-3 text-muted small" style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" :title="pkg.description">
              {{ pkg.description || '—' }}
            </td>
            <td class="px-4 py-3 fw-semibold text-muted"><s>{{ formatPrice(pkg.price) }}</s></td>
            <td class="px-4 py-3 fw-semibold text-success">{{ pkg.discount ? formatPrice(pkg.discount) : '—' }}</td>
            <td class="px-4 py-3">
              <span class="badge rounded-pill px-3 py-2 fw-medium" :style="pkg.isActive ? 'background:#ebf2ee;color:#4e7c66;font-size:0.72rem;' : 'background:#f0f0f0;color:#6c757d;font-size:0.72rem;'">
                {{ pkg.isActive ? 'Đang hoạt động' : 'Tạm ẩn' }}
              </span>
            </td>
            <td class="px-4 py-3">
              <div class="d-flex align-items-center justify-content-center gap-2">
                <button @click.stop="openEdit(pkg)" class="btn btn-sm btn-outline-primary rounded-3" title="Sửa">
                  <PencilSquareIcon style="width:16px;height:16px;" />
                </button>
                <button 
                  @click.stop="toggleActive(pkg)" 
                  class="btn btn-sm rounded-3"
                  :class="pkg.isActive ? 'btn-outline-warning' : 'btn-outline-success'"
                  :title="pkg.isActive ? 'Khóa' : 'Mở khóa'"
                >
                  <component :is="pkg.isActive ? LockClosedIcon : LockOpenIcon" style="width:16px;height:16px;" />
                </button>
              </div>
            </td>
          </tr>
          
          <!-- Detail Row -->
          <tr v-if="expandedPackageId === pkg.packageId" style="background:#fafdfb;">
            <td colspan="9" class="px-4 py-4">
              <div class="bg-white p-4 rounded-3 shadow-sm border d-flex flex-wrap gap-4">
                <!-- Left: Info -->
                <div class="flex-grow-1">
                  <h4 class="fw-bold text-dark mb-2 small">Chi tiết gói: <span class="text-success">{{ pkg.packageName }}</span></h4>
                  <p class="small text-secondary mb-3" style="white-space:pre-wrap;">{{ pkg.description }}</p>
                  <div class="row g-3 small">
                    <div class="col-6">
                      <span class="text-muted fw-medium">Thời gian bắt đầu:</span><br/>
                      <span class="fw-semibold text-dark">{{ pkg.startDate ? new Date(pkg.startDate).toLocaleString('vi-VN') : 'Không giới hạn' }}</span>
                    </div>
                    <div class="col-6">
                      <span class="text-muted fw-medium">Thời gian kết thúc:</span><br/>
                      <span class="fw-semibold text-dark">{{ pkg.endDate ? new Date(pkg.endDate).toLocaleString('vi-VN') : 'Không giới hạn' }}</span>
                    </div>
                  </div>
                </div>
                <!-- Right: Products -->
                <div class="flex-grow-1 ps-4" style="border-left:1px solid #dee2e6;">
                  <h4 class="fw-bold text-dark mb-3 small d-flex align-items-center gap-2">
                    Thành phần gói
                    <span class="badge rounded-pill fw-medium" style="background:#ebf2ee;color:#4e7c66;">{{ pkg.items?.length || 0 }} món</span>
                  </h4>
                  <div class="d-flex flex-column gap-2" style="max-height:160px;overflow-y:auto;" v-if="pkg.items && pkg.items.length > 0">
                    <div v-for="(item, idx) in pkg.items" :key="idx" class="d-flex justify-content-between align-items-center px-3 py-2 rounded-3 border" style="background:#f8f9fa;">
                      <span class="fw-medium small text-dark">{{ item.productName || getProductName(item.productId) }}</span>
                      <span class="badge rounded-pill fw-bold" style="background:#ebf2ee;color:#4e7c66;">SL: {{ item.quantity }}</span>
                    </div>
                  </div>
                  <div v-else class="small text-muted fst-italic p-3 rounded-3 border text-center" style="background:#f8f9fa;">Gói này chưa có sản phẩm nào.</div>
                </div>
              </div>
            </td>
          </tr>
          </template>
        </tbody>
      </table>

      <!-- Pagination Footer (Bootstrap 5) -->
      <div v-if="totalPages > 1" class="d-flex flex-column flex-md-row align-items-center justify-content-between bg-white p-3 border-top gap-3">
        <div class="small text-muted">
          Hiển thị <b>{{ (currentPage - 1) * itemsPerPage + 1 }}</b> - <b>{{ Math.min(currentPage * itemsPerPage, filteredPackages.length) }}</b> trên tổng số <b>{{ filteredPackages.length }}</b> gói
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
      <div v-if="showModal" class="fixed ff-modal-overlay d-flex align-items-center justify-content-center">
        <div class="position-absolute top-0 start-0 w-100 h-100" style="background:rgba(0,0,0,0.5);" @click="closeModal" />
        <div
          class="bg-white rounded-4 shadow-lg w-100 position-relative p-4"
          style="max-width:600px;z-index:10;max-height:calc(100vh - 4rem);overflow-y:auto;"
        >
          <div class="d-flex align-items-center justify-content-between mb-3">
            <h2 class="fw-bold text-dark fs-6 mb-0">
              {{ isEditing ? 'Chỉnh sửa gói sản phẩm' : 'Thêm gói sản phẩm mới' }}
            </h2>
            <button @click="closeModal" class="btn btn-sm btn-light rounded-circle">
              <XMarkIcon style="width:16px;height:16px;" class="text-muted" />
            </button>
          </div>

          <div class="d-flex flex-column gap-3">
            <!-- Mã gói -->
            <div>
              <label class="form-label small fw-semibold text-muted">
                Mã gói <span class="text-danger">*</span>
              </label>
              <input
                v-model="form.packageCode"
                type="text"
                placeholder="VD: PKG001"
                class="form-control rounded-3"
              />
            </div>

            <!-- Tên gói -->
            <div>
              <label class="form-label small fw-semibold text-muted">
                Tên gói (Combo) <span class="text-danger">*</span>
              </label>
              <input
                v-model="form.packageName"
                type="text"
                placeholder="VD: Combo rau lẩu cuối tuần"
                class="form-control rounded-3"
              />
            </div>

            <!-- Mô tả -->
            <div>
              <label class="form-label small fw-semibold text-muted">
                Mô tả (Bắt buộc) <span class="text-danger">*</span>
              </label>
              <textarea
                v-model="form.description"
                rows="2"
                placeholder="VD: Bao gồm cà chua, rau muống, nấm..."
                class="form-control rounded-3"
              />
            </div>

            <!-- Ảnh gói sản phẩm -->
            <div>
              <label class="form-label small fw-semibold text-muted">
                Ảnh gói sản phẩm
              </label>
              <input
                type="file"
                accept="image/*"
                @change="handleFileUpload"
                class="form-control rounded-3"
              />
              <!-- Hiển thị ảnh xem trước -->
              <div v-if="form.image" class="mt-2">
                <img :src="getImageUrl(form.image)" alt="Preview" class="rounded-3 border" style="width:80px;height:80px;object-fit:cover;" />
              </div>
            </div>

            <div class="mt-3 pt-3 border-top">
              <h3 class="fw-bold text-dark small mb-3">Sản phẩm trong Combo</h3>
              
              <!-- Danh sách đã thêm -->
              <div class="mb-3 d-flex flex-column gap-2" style="max-height:130px;overflow-y:auto;">
                 <div v-for="(item, idx) in form.items" :key="idx" class="d-flex justify-content-between align-items-center px-3 py-2 rounded-3 border" style="background:#f8f9fa;">
                   <div class="fw-medium small text-dark">
                     {{ item.productName || getProductName(item.productId) }} 
                     <span class="badge rounded-pill ms-1 fw-bold" style="background:#ebf2ee;color:#4e7c66;">SL: {{ item.packageQuantity }}</span>
                   </div>
                   <button type="button" @click="removeItem(idx)" class="btn btn-sm btn-outline-danger rounded-3 p-1">
                     <TrashIcon style="width:14px;height:14px;"/>
                   </button>
                 </div>
                 <div v-if="form.items.length === 0" class="text-muted fst-italic small">Chưa có sản phẩm nào trong gói</div>
              </div>

              <!-- Thêm sản phẩm mới vào danh sách -->
              <div class="d-flex gap-2 align-items-end p-3 rounded-3 border" style="background:#f8f9fa;">
                <div class="flex-grow-1">
                  <label class="form-label small fw-semibold text-muted">Chọn Sản phẩm</label>
                  <select v-model="selectedProductId" class="form-select rounded-3 small">
                    <option :value="null" disabled>Chọn sản phẩm...</option>
                    <option v-for="p in allProducts" :key="p.productId" :value="p.productId">{{ p.productName }}</option>
                  </select>
                </div>
                <div style="width:100px;">
                  <label class="form-label small fw-semibold text-muted">Số lượng</label>
                  <input v-model.number="selectedPackageQuantity" type="number" step="0.1" min="0.1" class="form-control rounded-3 text-center small" />
                </div>
                <button type="button" @click="addItem" class="btn btn-outline-success fw-bold small rounded-3">Thêm</button>
              </div>
            </div>

            <!-- Giá cả -->
            <div class="row g-3">
              <div>
                <label class="form-label small fw-semibold text-muted">
                  Giá gốc (VNĐ) <span class="text-danger">*</span>
                </label>
                <input
                  v-model.number="form.basePrice"
                  type="number"
                  placeholder="VD: 150000"
                  class="form-control rounded-3"
                />
              </div>
              <div>
                <label class="form-label small fw-semibold text-muted">
                  Giá khuyến mãi (VNĐ)
                </label>
                <input
                  v-model.number="form.discountPrice"
                  type="number"
                  placeholder="Không bắt buộc"
                  class="form-control rounded-3"
                />
              </div>
            </div>

            <!-- Hạn mức khuyến mãi -->
            <div class="mb-3">
              <label class="form-label small fw-semibold text-muted">
                Số lượng khuyến mãi (Hạn mức bán)
              </label>
              <input
                v-model.number="form.maxQuantity"
                type="number"
                placeholder="Không bắt buộc (Để trống để bán không giới hạn)"
                class="form-control rounded-3"
              />
            </div>

            <!-- Thời gian (Tuỳ chọn) -->
            <div class="row g-3 mb-3">
              <div class="col-6">
                <label class="form-label small fw-semibold text-muted">Ngày bắt đầu</label>
                <input v-model="form.startDate" type="datetime-local" class="form-control rounded-3" />
              </div>
              <div class="col-6">
                <label class="form-label small fw-semibold text-muted">Ngày kết thúc</label>
                <input v-model="form.endDate" type="datetime-local" class="form-control rounded-3" />
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

          <div class="d-flex gap-3 mt-4">
            <button @click="closeModal" class="btn btn-outline-secondary flex-grow-1 rounded-3 fw-semibold small">Hủy</button>
            <button @click="savePackage" :disabled="saving" class="btn btn-success flex-grow-1 rounded-3 fw-semibold small">
              <span v-if="saving" class="spinner-border spinner-border-sm me-1"></span>
              {{ saving ? 'Đang xử lý...' : 'Lưu' }}
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
import axios from 'axios'
import { toast } from '@/utils/toast'
import {
  PlusIcon,
  MagnifyingGlassIcon,
  PencilSquareIcon,
  XMarkIcon,
  ChevronLeftIcon,
  ChevronRightIcon,
  LockClosedIcon,
  LockOpenIcon,
  TrashIcon
} from '@heroicons/vue/24/outline'

const props = defineProps({
  searchQuery: { type: String, default: '' }
})

// ── Helpers ────────────────────────────────────────────────────────────────
const removeAccents = (str) => {
  return str ? str.normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd').replace(/Đ/g, 'D') : '';
}

function formatPrice(value) {
  return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(value)
}

const BASE_URL = import.meta.env.VITE_API_URL || window.location.origin

function getImageUrl(url) {
  if (!url) return '';
  if (url.startsWith('data:image')) return url; // Base64 preview khi vừa chọn file
  if (url.startsWith('http')) return url; // Đã là link đầy đủ
  return `${BASE_URL}${url.startsWith('/') ? '' : '/'}${url}`;
}

// ── State ──────────────────────────────────────────────────────────────────
const showModal = ref(false)
const isEditing = ref(false)
const loading = ref(false)
const saving = ref(false)
const expandedPackageId = ref(null)

function toggleExpand(pkg) {
  if (expandedPackageId.value === pkg.packageId) {
    expandedPackageId.value = null
  } else {
    expandedPackageId.value = pkg.packageId
  }
}

const emptyForm = () => ({
  packageId: 0,
  packageCode: '',
  packageName: '',
  description: '',
  basePrice: 0,
  discountPrice: null,
  maxQuantity: null,
  stockLimit: 0,
  image: '',
  imageFile: null,
  startDate: null,
  endDate: null,
  isActive: true,
  items: [] // Mảng chứa các PackageItemDto.Request { productId, packageQuantity }
})
const form = ref(emptyForm())

const packages = ref([])
const allProducts = ref([])

const selectedProductId = ref(null)
const selectedPackageQuantity = ref(1)

// Pagination state
const currentPage = ref(1)
const itemsPerPage = ref(10)

const fetchPackages = async () => {
  loading.value = true
  try {
    const response = await apiClient.get('/Package')
    packages.value = response.data.data || response.data || []
  } catch (error) {
    console.error('Lỗi khi tải dữ liệu gói sản phẩm:', error)
    toast.error('Không thể tải dữ liệu gói sản phẩm từ máy chủ!')
  } finally {
    loading.value = false
    // Reset an toàn trang hiện tại nếu bị vượt quá giới hạn
    if (currentPage.value > totalPages.value) {
      currentPage.value = Math.max(1, totalPages.value)
    }
  }
}

const fetchProducts = async () => {
  try {
    const response = await apiClient.get('/Product')
    allProducts.value = response.data.data || response.data || []
  } catch (error) {
    console.error('Lỗi khi tải danh sách sản phẩm:', error)
  }
}

onMounted(() => {
  fetchPackages()
  fetchProducts()
})

// ── Item Management ────────────────────────────────────────────────────────
function getProductName(productId) {
  const p = allProducts.value.find(x => x.productId === productId)
  return p ? p.productName : 'Sản phẩm không xác định'
}

function addItem() {
  if (!selectedProductId.value) {
    toast.warning('Vui lòng chọn sản phẩm!')
    return
  }
  if (!selectedPackageQuantity.value || selectedPackageQuantity.value <= 0) {
    toast.warning('Khối lượng/Số lượng phải lớn hơn 0')
    return
  }
  
  // Kiểm tra xem đã có trong list chưa
  const existing = form.value.items.find(x => x.productId === selectedProductId.value)
  if (existing) {
    existing.packageQuantity += selectedPackageQuantity.value
  } else {
    form.value.items.push({
      productId: selectedProductId.value,
      packageQuantity: selectedPackageQuantity.value
    })
  }
  
  // Reset input thêm
  selectedProductId.value = null
  selectedPackageQuantity.value = 1
}

function removeItem(index) {
  form.value.items.splice(index, 1)
}

// ── Computed ───────────────────────────────────────────────────────────────
const filteredPackages = computed(() => {
  const query = removeAccents(props.searchQuery).toLowerCase().trim()
  if (!query) return packages.value
  return packages.value.filter(p => {
    const codeMatch = p.packageCode ? removeAccents(p.packageCode).toLowerCase().includes(query) : false
    const nameMatch = p.packageName ? removeAccents(p.packageName).toLowerCase().includes(query) : false
    const descMatch = p.description ? removeAccents(p.description).toLowerCase().includes(query) : false
    return codeMatch || nameMatch || descMatch
  })
})

watch(() => props.searchQuery, () => {
  currentPage.value = 1
})

const totalPages = computed(() => Math.ceil(filteredPackages.value.length / itemsPerPage.value))

const paginatedPackages = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  return filteredPackages.value.slice(start, start + itemsPerPage.value)
})

// ── Methods ────────────────────────────────────────────────────────────────

function handleFileUpload(event) {
  const file = event.target.files[0]
  if (!file) return

  // Lưu file thực tế vào form để lát nữa gửi chung lúc ấn "Lưu thay đổi"
  form.value.imageFile = file

  // Tạo URL tạm để hiển thị preview ngay lập tức
  const reader = new FileReader()
  reader.onload = (e) => {
    form.value.image = e.target.result 
  }
  reader.readAsDataURL(file)
}

function openAdd() {
  isEditing.value = false
  form.value = emptyForm()
  showModal.value = true
}

function openEdit(pkg) {
  isEditing.value = true
  form.value = {
    packageId: pkg.packageId,
    packageCode: pkg.packageCode || '',
    packageName: pkg.packageName,
    description: pkg.description,
    image: pkg.imageUrl || '',
    imageFile: null,
    basePrice: pkg.price || 0,
    discountPrice: pkg.discount || 0,
    maxQuantity: pkg.maxQuantity,
    stockLimit: pkg.stockLimit || 0,
    startDate: pkg.startDate ? new Date(pkg.startDate).toISOString().slice(0, 16) : null,
    endDate: pkg.endDate ? new Date(pkg.endDate).toISOString().slice(0, 16) : null,
    isActive: pkg.isActive !== false,
    // Map response items về dạng request format (giữ lại productName để hiện UI)
    items: (pkg.items || []).map(i => ({ productId: i.productId, packageQuantity: i.quantity, productName: i.productName }))
  }
  showModal.value = true
}

function closeModal() {
  showModal.value = false
  form.value = emptyForm()
  selectedProductId.value = null
  selectedPackageQuantity.value = 1
}

const validatePackageForm = () => {
  // Định nghĩa các field bắt buộc
  const requiredFields = {
    'packageCode': 'Mã gói sản phẩm',
    'packageName': 'Tên gói sản phẩm',
    'description': 'Mô tả',
    'basePrice': 'Giá gốc',
  }
  
  // Kiểm tra từng field
  for (const [field, fieldName] of Object.entries(requiredFields)) {
    const value = form.value[field]
    // Check nếu field trống (cho phép 0) hoặc chỉ có khoảng trắng
    if (value === undefined || value === null || value === '' || (typeof value === 'string' && !value.trim())) {
      toast.warning('Vui lòng nhập đầy đủ thông tin!')
      return false
    }
  }
  
  return true
}

// prepareFormData đã bị loại bỏ do chuyển sang API truyền tải dữ liệu JSON [FromBody] trực tiếp.

/**
 * Trích xuất error message từ API response
 * @param {Error} error - Error object từ API
 * @returns {string} Error message đã format
 */
const getErrorMessage = (error) => {
  // Ưu tiên message → title → error message
  let msg = error.response?.data?.message || 
            error.response?.data?.title || 
            error.message
  
  // Nếu có chi tiết validation error, thêm vào
  if (error.response?.data?.errors) {
    msg += '\n' + Object.values(error.response.data.errors).flat().join('\n')
  }
  
  return msg
}

/**
 * Lưu gói sản phẩm (thêm mới hoặc cập nhật)
 * Logic:
 * 1. Validate dữ liệu
 * 2. Chuẩn bị FormData (bao gồm file upload)
 * 3. Gửi API với method & endpoint phù hợp
 * 4. Reload danh sách và đóng modal
 */
async function savePackage() {
  if (!validatePackageForm()) return

  saving.value = true
  try {
    const token = localStorage.getItem('token')
    const config = {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    }

    // STEP 1: Upload ảnh trước nếu có file mới
    let imageUrl = form.value.image || null
    
    // Loại bỏ chuỗi base64 preview nếu người dùng chọn lại ảnh nhưng không upload
    if (imageUrl && imageUrl.startsWith('data:image')) {
      imageUrl = null
    }

    if (form.value.imageFile) {
      const formData = new FormData()
      formData.append('image', form.value.imageFile)

      const uploadRes = await axios.post(
        `${BASE_URL}/api/Package/upload-image`,
        formData,
        {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'multipart/form-data'
          }
        }
      )
      // Hỗ trợ cả camelCase và PascalCase tự động
      imageUrl = uploadRes.data.imageUrl || uploadRes.data.ImageUrl || uploadRes.data
    }

    // STEP 2: Gửi JSON body
    const payload = {
      packageCode: form.value.packageCode,
      packageName: form.value.packageName,
      description: form.value.description,
      imageUrl: imageUrl,
      price: form.value.basePrice,
      discount: form.value.discountPrice || 0,
      maxQuantity: form.value.maxQuantity || 999999,
      startDate: form.value.startDate
        ? new Date(form.value.startDate).toISOString()
        : null,
      endDate: form.value.endDate
        ? new Date(form.value.endDate).toISOString()
        : null,
      packageType: '',
      isActive: form.value.isActive,
      items: form.value.items.map(i => ({
        productId: i.productId,
        quantity: i.packageQuantity
      }))
    }

    if (isEditing.value) {
      payload.packageId = form.value.packageId
      await axios.put(`${BASE_URL}/api/Package/update`, payload, config)
    } else {
      await axios.post(`${BASE_URL}/api/Package/add`, payload, config)
    }

    await fetchPackages()
    closeModal()
    toast.success(isEditing.value ? 'Cập nhật Combo thành công!' : 'Tạo Combo mới thành công!')
  } catch (error) {
    toast.error('Lỗi khi lưu dữ liệu: ' + getErrorMessage(error))
  } finally {
    saving.value = false
  }
}

async function toggleActive(pkg) {
  try {
    const payload = {
      packageId: pkg.packageId,
      packageCode: pkg.packageCode,
      packageName: pkg.packageName,
      description: pkg.description,
      imageUrl: pkg.imageUrl,
      price: pkg.price,
      discount: pkg.discount || 0,
      maxQuantity: pkg.maxQuantity || 999999,
      startDate: pkg.startDate,
      endDate: pkg.endDate,
      packageType: pkg.packageType || '',
      isActive: !pkg.isActive,
      items: pkg.items ? pkg.items.map(i => ({
        productId: i.productId,
        quantity: i.packageQuantity || i.quantity || 0
      })) : []
    }
    await apiClient.put('/Package/update', payload)
    await fetchPackages()
    toast.success(pkg.isActive ? 'Khóa Combo thành công!' : 'Mở khóa Combo thành công!')
  } catch (error) {
    toast.error('Lỗi khi cập nhật Combo: ' + getErrorMessage(error))
  }
}
</script>

<style scoped>
.ff-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 1050;
}
</style>
