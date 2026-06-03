<script setup>
import { onMounted } from 'vue'
import { ShieldCheckIcon, TruckIcon, HeartIcon, GlobeAltIcon, SparklesIcon, PhoneIcon } from '@heroicons/vue/24/outline'

const emit = defineEmits(['navigate'])

const milestones = [
  { year: '2019', title: 'Khởi đầu', desc: 'FreshFarm ra đời từ ý tưởng giải cứu những củ cà rốt cong queo, quả cà chua méo mó bị từ chối ở các siêu thị lớn.' },
  { year: '2020', title: 'Hợp tác nhà vườn', desc: 'Bắt đầu liên kết với 50 hộ nông dân tại Đà Lạt để bao tiêu toàn bộ nông sản "xấu mã" nhưng chất lượng.' },
  { year: '2022', title: '100 Tấn nông sản', desc: 'Chính thức cán mốc 100 tấn rau củ được cứu khỏi việc bị vứt bỏ lãng phí tại các nông trại.' },
  { year: '2024', title: 'Lan tỏa cộng đồng', desc: 'Phát động chiến dịch "Xấu mã nhưng ngọt lòng", thay đổi thói quen tiêu dùng của hàng ngàn gia đình.' },
  { year: '2026', title: '10.000+ Khách hàng', desc: 'Cộng đồng yêu nông sản "méo mó" không ngừng lớn mạnh, cùng nhau tạo nên lối sống xanh bền vững.' }
]

const values = [
  { icon: HeartIcon,        title: 'Tôn trọng giá trị thực', desc: 'Vẻ ngoài không hoàn hảo nhưng hương vị, độ tươi và dinh dưỡng luôn 100% nguyên vẹn.',            colorClass: 'bg-success bg-opacity-10 text-success' },
  { icon: GlobeAltIcon,     title: 'Giảm lãng phí',          desc: 'Góp phần cứu hàng ngàn tấn thức ăn ngon lành khỏi bãi rác mỗi năm, bảo vệ môi trường.',           colorClass: 'bg-primary bg-opacity-10 text-primary' },
  { icon: ShieldCheckIcon,  title: 'Hỗ trợ nông dân',        desc: 'Giúp bà con nông dân có thêm thu nhập từ những sản phẩm vốn bị bỏ đi một cách đáng tiếc.',         colorClass: 'bg-danger bg-opacity-10 text-danger' },
  { icon: SparklesIcon,     title: 'Tiết kiệm chi phí',      desc: 'Giá thành rẻ hơn 30-50% so với nông sản chuẩn siêu thị, giúp gia đình bạn tiết kiệm đáng kể.',   colorClass: 'bg-warning bg-opacity-10 text-warning' }
]

const stats = [
  { number: '10,000+', label: 'Khách hàng tin dùng' },
  { number: '500+',    label: 'Tấn nông sản được cứu' },
  { number: '200+',    label: 'Nông trại liên kết' },
  { number: '30%',     label: 'Chi phí tiết kiệm' }
]

onMounted(() => {
  document.title = 'Về chúng tôi | FreshFarm - Nông sản "xấu mã" chất lượng tuyệt vời'
})
</script>

<template>
  <div style="">
    <!-- Hero -->
    <section class="ff-hero" style="height:320px;">
      <img
        src="https://images.unsplash.com/photo-1500937386664-56d1dfef3854?ixlib=rb-1.2.1&auto=format&fit=crop&w=1600&q=80"
        alt="Cánh đồng nông trại xanh tươi FreshFarm"
      />
      <div class="ff-hero-overlay"></div>
      <div class="ff-hero-content text-center">
        <div class="container-xl px-3 px-sm-4">
          <span class="badge rounded-pill mb-3 d-inline-flex align-items-center gap-1"
            style="background:rgba(255,255,255,0.12);color:#6ee7b7;border:1px solid rgba(255,255,255,0.2);font-size:0.7rem;padding:6px 14px;backdrop-filter:blur(4px);">
            🌱 Vẻ đẹp đích thực nằm ở hương vị
          </span>
          <h1 class="text-white fw-extrabold lh-sm mb-2" style="font-size:clamp(1.6rem,4vw,2.5rem);">
            Câu chuyện của <span style="color:#6ee7b7;">Nông sản "Méo Mó"</span>
          </h1>
          <p class="mx-auto mb-0" style="color:rgba(255,255,255,0.75);font-size:0.9rem;line-height:1.7;max-width:480px;">
            Chúng tôi giải cứu những mặt hàng nông sản bị từ chối chỉ vì vẻ ngoài không hoàn hảo,
            mang đến cho bạn bữa ăn tươi ngon với mức giá vô cùng tiết kiệm.
          </p>
        </div>
      </div>
    </section>

    <!-- Mission -->
    <section aria-labelledby="mission-heading" class="container-xl px-3 px-sm-4 py-5">
      <div class="row g-5 align-items-center">
        <div class="col-12 col-lg-6">
          <h2 id="mission-heading" class="fw-extrabold text-dark mb-3" style="font-size:1.5rem;">Sứ mệnh của chúng tôi</h2>
          <p class="small text-muted lh-lg mb-3">
            Mỗi năm, hàng nghìn tấn rau củ quả tươi ngon bị vứt bỏ tại các trang trại chỉ vì chúng bị cong, méo,
            hay có kích thước không đạt chuẩn thẩm mỹ khắt khe của siêu thị.
            <strong class="text-dark">FreshFarm ra đời để thay đổi điều đó.</strong>
          </p>
          <p class="small text-muted lh-lg mb-4">
            Bằng việc bao tiêu các loại nông sản <strong class="text-dark">"xấu mã"</strong> nhưng chất lượng bên trong
            hoàn toàn không suy giảm, chúng tôi mang lại giải pháp mua sắm tiết kiệm cho bạn,
            tăng thu nhập cho người nông dân và giảm tải lãng phí thực phẩm cho xã hội.
          </p>
          <!-- Stats -->
          <div class="row row-cols-2 g-3">
            <div class="col" v-for="stat in stats" :key="stat.label">
              <div class="text-center p-3 rounded-xl" style="background:#ebf2ee;">
                <div class="fw-extrabold text-success" style="font-size:1.3rem;">{{ stat.number }}</div>
                <div class="text-muted fw-medium" style="font-size:0.7rem;">{{ stat.label }}</div>
              </div>
            </div>
          </div>
        </div>
        <div class="col-12 col-lg-6">
          <div class="rounded-2xl overflow-hidden shadow-sm border" style="border-color:#f3f4f6;">
            <img
              src="https://images.unsplash.com/photo-1598030304671-5aa1d6f21128?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80"
              alt="Nông sản tươi ngon với hình dáng tự nhiên tại FreshFarm"
              class="w-100 object-cover"
              style="height:260px;"
              loading="lazy"
            />
          </div>
        </div>
      </div>
    </section>

    <!-- Core Values -->
    <section aria-labelledby="values-heading" class="py-5" style="background:#f8faf5;">
      <div class="container-xl px-3 px-sm-4">
        <div class="text-center mb-5">
          <h2 id="values-heading" class="fw-extrabold text-dark mb-1" style="font-size:1.5rem;">Giá trị cốt lõi</h2>
          <p class="text-muted small mb-0">Những cam kết không thay đổi của FreshFarm</p>
        </div>
        <div class="row row-cols-1 row-cols-sm-2 row-cols-lg-4 g-4">
          <div class="col" v-for="value in values" :key="value.title">
            <div class="bg-white rounded-xl p-4 border shadow-sm h-100" style="border-color:#f3f4f6;transition:box-shadow 0.2s;">
              <div :class="['d-inline-flex align-items-center justify-content-center rounded-xl mb-3', value.colorClass]"
                style="width:44px;height:44px;">
                <component :is="value.icon" style="width:20px;height:20px;" />
              </div>
              <h3 class="fw-bold text-dark small mb-1">{{ value.title }}</h3>
              <p class="text-muted mb-0" style="font-size:0.78rem;line-height:1.6;">{{ value.desc }}</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Timeline -->
    <section aria-labelledby="timeline-heading" class="container-xl px-3 px-sm-4 py-5">
      <div class="text-center mb-5">
        <h2 id="timeline-heading" class="fw-extrabold text-dark mb-1" style="font-size:1.5rem;">Hành trình phát triển</h2>
        <p class="text-muted small mb-0">Những cột mốc quan trọng của FreshFarm</p>
      </div>

      <!-- Timeline list (simple vertical on all sizes) -->
      <div class="position-relative" style="padding-left:2rem;">
        <!-- Vertical line -->
        <div class="position-absolute bg-success bg-opacity-25 rounded-pill"
          style="left:0.75rem;top:0;bottom:0;width:2px;"></div>

        <div class="d-flex flex-column gap-4">
          <div v-for="(milestone, index) in milestones" :key="milestone.year" class="position-relative">
            <!-- Dot -->
            <div class="position-absolute rounded-circle bg-success border border-2 border-white shadow"
              style="width:14px;height:14px;left:-1.9rem;top:0.25rem;z-index:1;"></div>
            <!-- Card -->
            <div class="bg-white rounded-xl p-4 border shadow-sm" style="border-color:#f3f4f6;">
              <span class="badge rounded-pill bg-success bg-opacity-10 text-success fw-bold mb-2" style="font-size:0.7rem;">{{ milestone.year }}</span>
              <h3 class="fw-bold text-dark small mb-1">{{ milestone.title }}</h3>
              <p class="text-muted mb-0" style="font-size:0.78rem;line-height:1.6;">{{ milestone.desc }}</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA -->
    <section class="py-5 bg-success">
      <div class="container-xl px-3 px-sm-4 text-center">
        <SparklesIcon class="text-white mx-auto mb-3" style="width:32px;height:32px;opacity:0.7;" />
        <h2 class="fw-extrabold text-white mb-2" style="font-size:1.5rem;">Chung tay chống lãng phí thực phẩm?</h2>
        <p class="text-white mb-4 mx-auto" style="opacity:0.85;font-size:0.875rem;max-width:400px;">
          Khám phá các combo nông sản tươi ngon, hình dáng "vui nhộn" với mức giá cực kỳ ưu đãi.
        </p>
        <div class="d-flex justify-content-center gap-3 flex-wrap">
          <a href="#" @click.prevent="$emit('navigate', 'products')"
            class="btn btn-light fw-semibold rounded-pill px-4 py-2 text-success">
            Mua sắm ngay
          </a>
          <a href="tel:19001234"
            class="btn btn-outline-light fw-semibold rounded-pill px-4 py-2 d-flex align-items-center gap-2">
            <PhoneIcon style="width:16px;height:16px;" />
            1900 1234
          </a>
        </div>
      </div>
    </section>
  </div>
</template>
