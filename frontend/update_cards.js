const fs = require('fs');

const filesToUpdate = [
  'd:/freshfarm/src/components/layout/customer/HomeView.vue',
  'd:/freshfarm/src/components/layout/customer/ProductView.vue'
];

filesToUpdate.forEach(file => {
  let content = fs.readFileSync(file, 'utf8');

  // Replace colors
  content = content.replace(/#92c83e/g, '#16a34a');
  content = content.replace(/#8cc63f/g, '#16a34a');

  // Remove description paragraphs
  // It looks like:
  // <p class="text-muted mb-3" style="font-size: 0.85rem; line-height: 1.4; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">
  //   {{ product.description || 'Giao rau tận nhà nội thành TP HCM. Ngoài ra Chúng tôi hiện đang cung cấp nhiều loại thực phẩm tươi sạch khác.' }}
  // </p>
  const descRegex = /<p class="text-muted mb-3"[^>]*>[\s\S]*?<\/p>/g;
  content = content.replace(descRegex, '');

  fs.writeFileSync(file, content);
  console.log('Updated ' + file);
});

console.log('Done!');
