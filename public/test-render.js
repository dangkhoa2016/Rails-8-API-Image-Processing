const { createApp } = Vue;

// ==========================================
// TỪ ĐIỂN NGÔN NGỮ (LANGUAGE DICTIONARY)
// Dịch các giá trị (values) bên dưới để đổi ngôn ngữ
// ==========================================
const I18N = {
  auth: {
    missingFields: "Hãy nhập đầy đủ API Base URL, email và password.",
    loginSuccess: "Đăng nhập thành công:",
    loginFailed: "Đăng nhập thất bại",
    missingAuthHeader:
      "Không đọc được Authorization header. Nếu trang khác origin, hãy kiểm tra CORS expose headers.",
    defaultError: "Đăng nhập thất bại.",
  },
  render: {
    missingPrerequisites:
      "Cần đăng nhập và nhập remote image URL hợp lệ trước khi render.",
    sendingRequest: "Đang gửi request...",
    renderFailed: "Render thất bại",
    loadedIn: "Tải xong trong", // Sẽ tự động nối thêm số mili-giây (VD: Tải xong trong 150 ms.)
    loadErrorDefault: "Không tải được ảnh.",
    decodeError:
      "Response decode được thành binary, nhưng browser không render được ảnh.",
    previewUnavailable:
      "Render thành công nhưng trình duyệt hiện tại không preview được định dạng này.",
    previewUnavailableTitle: "Preview không khả dụng",
    parametersUpdated: "Đã cập nhật cấu hình. Bấm render lại để chạy URL mới.",
  },
  status: {
    queued: "Đang xếp hàng",
    loading: "Đang tải",
    done: "Hoàn thành",
    error: "Lỗi",
  },
  scenarios: {
    original: {
      label: "Ảnh gốc",
      note: "Không transform, chỉ đi qua pipeline download + auth.",
    },
    "resize-half": { label: "Resize 50%", note: "resize=0.5" },
    "resize-box": {
      label: "Resize 320x320",
      note: "resize[width]=320, resize[height]=320",
    },
    "crop-top-left": { label: "Crop 160x160", note: "crop[]=0,0,160,160" },
    "rotate-jpg": { label: "Rotate 90 + JPG", note: "rotate=90, toFormat=jpg" },
    "flip-horizontal": { label: "Flip Horizontal", note: "flip=horizontal" },
    gaussblur: { label: "Gauss Blur", note: "gaussblur=2" },
    sharpen: { label: "Sharpen", note: "sharpen[sigma]=2" },
    grayscale: { label: "Grayscale", note: "colourspace=b-w" },
    webp: { label: "Convert WEBP", note: "toFormat=webp" },
  },
};

// ==========================================
// CẤU HÌNH GIAO DIỆN & STYLE
// ==========================================
const UI = {
  panel:
    "rounded-[24px] border border-stone-900/12 bg-white/80 p-5 shadow-[0_24px_64px_rgba(75,52,31,0.12)] backdrop-blur-sm sm:p-[22px]",
  field:
    "w-full rounded-2xl border border-stone-900/15 bg-white/85 px-4 py-3 text-stone-900 shadow-sm outline-none transition duration-200 focus:-translate-y-px focus:border-[#b45f35]/40 focus:ring-4 focus:ring-[#b45f35]/10 disabled:cursor-not-allowed disabled:opacity-60",
  primaryButton:
    "inline-flex items-center justify-center rounded-full bg-gradient-to-br from-[#b45f35] to-[#8d4420] px-5 py-3 font-semibold text-amber-50 shadow-[0_14px_26px_rgba(180,95,53,0.22)] transition duration-200 hover:-translate-y-0.5 disabled:cursor-not-allowed disabled:opacity-55",
  secondaryButton:
    "inline-flex items-center justify-center rounded-full border border-stone-900/12 bg-white/75 px-5 py-3 font-semibold text-stone-900 transition duration-200 hover:-translate-y-0.5 disabled:cursor-not-allowed disabled:opacity-55",
  noticeSuccess:
    "rounded-2xl border border-emerald-700/15 bg-emerald-700/10 px-4 py-3 text-emerald-900 leading-6",
  noticeError:
    "rounded-2xl border border-rose-700/15 bg-rose-700/10 px-4 py-3 text-rose-900 leading-6",
  compactField:
    "w-full rounded-xl border border-stone-900/12 bg-white/90 px-3 py-2.5 text-sm text-stone-900 shadow-sm outline-none transition duration-200 focus:-translate-y-px focus:border-[#b45f35]/40 focus:ring-4 focus:ring-[#b45f35]/10 disabled:cursor-not-allowed disabled:opacity-60",
  cardButton:
    "inline-flex items-center justify-center rounded-full border border-[#b45f35]/18 bg-amber-50/80 px-4 py-2 text-sm font-semibold text-[#8d4420] transition duration-200 hover:-translate-y-0.5 disabled:cursor-not-allowed disabled:opacity-55",
  codeTextarea:
    "min-h-[132px] w-full rounded-2xl border border-stone-900/15 bg-white/85 px-4 py-3 text-[0.78rem] leading-6 text-stone-700 shadow-sm outline-none [font-family:IBM_Plex_Mono,_SFMono-Regular,_monospace]",
};

const SCENARIO_GROUPS = [
  {
    key: "custom-base",
    label: "Nhóm 1: Tùy chỉnh tự do",
    description: "Tạo request nền hoặc thử query tùy biến trước khi đi vào các transform cụ thể.",
  },
  {
    key: "resize-fit",
    label: "Nhóm 2: Resize & Fit",
    description: "Kiểm tra các biến thể đổi kích thước và chế độ fit thường gặp.",
  },
  {
    key: "crop-trim",
    label: "Nhóm 3: Crop & Trim",
    description: "Dùng khi cần test vùng cắt, crop thông minh và trim viền.",
  },
  {
    key: "orientation",
    label: "Nhóm 4: Orientation",
    description: "Bao phủ autorotate, rotate và flip theo nhiều hướng khác nhau.",
  },
  {
    key: "format-background",
    label: "Nhóm 5: Format, Quality & Background",
    description: "Kiểm tra output format, quality, flatten và màu nền đầu ra.",
  },
  {
    key: "filters",
    label: "Nhóm 6: Filters",
    description: "Chạy các bộ lọc màu sắc, làm mờ, sharpen và hiệu ứng xử lý ảnh.",
  },
  {
    key: "combos-overlays",
    label: "Nhóm 7: Combo & Overlay",
    description: "Các pipeline kết hợp nhiều transform hoặc trường hợp watermark/metadata.",
  },
  {
    key: "negative-boundaries",
    label: "Nhóm 8: Negative & Boundaries",
    description: "Dành cho test lỗi, boundary input và các case cố tình không hợp lệ.",
  },
];

const scenarioConfigs = [
  // ==========================================
  // NHÓM 1: TÙY CHỈNH TỰ DO (CUSTOM & BASE)
  // ==========================================
  {
    groupKey: "custom-base",
    key: "original",
    controls: [
      {
        key: "custom-query",
        label: "Custom query",
        value: "",
        placeholder: "rotate=90&toFormat=webp",
        inputMode: "text",
        rawQuery: true,
      },
    ],
  },

  // ==========================================
  // NHÓM 2: THAY ĐỔI KÍCH THƯỚC (RESIZE & FIT)
  // ==========================================
  {
    groupKey: "resize-fit",
    key: "resize-half",
    controls: [
      {
        key: "resize",
        param: "resize",
        label: "Scale",
        value: "0.5",
        placeholder: "0.5",
        inputMode: "decimal",
      },
    ],
  },
  {
    groupKey: "resize-fit",
    key: "resize-box",
    controls: [
      {
        key: "width",
        param: "resize[width]",
        label: "Width",
        value: "320",
        placeholder: "320",
        inputMode: "numeric",
      },
      {
        key: "height",
        param: "resize[height]",
        label: "Height",
        value: "320",
        placeholder: "320",
        inputMode: "numeric",
      },
    ],
  },
  {
    groupKey: "resize-fit",
    key: "resize-width-only",
    controls: [
      {
        key: "width",
        param: "resize[width]",
        label: "Width",
        value: "320",
        placeholder: "320",
        inputMode: "numeric",
      },
    ],
  },
  {
    groupKey: "resize-fit",
    key: "resize-height-only",
    controls: [
      {
        key: "height",
        param: "resize[height]",
        label: "Height",
        value: "320",
        placeholder: "320",
        inputMode: "numeric",
      },
    ],
  },
  {
    groupKey: "resize-fit",
    key: "resize-fit-inside",
    controls: [
      {
        key: "width",
        param: "resize[width]",
        label: "Width",
        value: "320",
        placeholder: "320",
        inputMode: "numeric",
      },
      {
        key: "height",
        param: "resize[height]",
        label: "Height",
        value: "320",
        placeholder: "320",
        inputMode: "numeric",
      },
      {
        key: "fit",
        param: "resize[fit]",
        label: "Fit",
        value: "inside",
        placeholder: "inside",
        inputMode: "text",
      },
    ],
  },
  {
    groupKey: "resize-fit",
    key: "resize-fit-cover",
    controls: [
      {
        key: "width",
        param: "resize[width]",
        label: "Width",
        value: "320",
        placeholder: "320",
        inputMode: "numeric",
      },
      {
        key: "height",
        param: "resize[height]",
        label: "Height",
        value: "320",
        placeholder: "320",
        inputMode: "numeric",
      },
      {
        key: "fit",
        param: "resize[fit]",
        label: "Fit",
        value: "cover",
        placeholder: "cover",
        inputMode: "text",
      },
    ],
  },
  {
    groupKey: "resize-fit",
    key: "resize-fit-contain",
    controls: [
      {
        key: "width",
        param: "resize[width]",
        label: "Width",
        value: "320",
        placeholder: "320",
        inputMode: "numeric",
      },
      {
        key: "height",
        param: "resize[height]",
        label: "Height",
        value: "320",
        placeholder: "320",
        inputMode: "numeric",
      },
      {
        key: "fit",
        param: "resize[fit]",
        label: "Fit",
        value: "contain",
        placeholder: "contain",
        inputMode: "text",
      },
    ],
  },

  // ==========================================
  // NHÓM 3: CẮT GỌT VÀ TỌA ĐỘ (CROP & TRIM)
  // ==========================================
  {
    groupKey: "crop-trim",
    key: "crop-top-left",
    controls: [
      {
        key: "left",
        param: "crop[]",
        label: "Left",
        value: "0",
        placeholder: "0",
        inputMode: "numeric",
      },
      {
        key: "top",
        param: "crop[]",
        label: "Top",
        value: "0",
        placeholder: "0",
        inputMode: "numeric",
      },
      {
        key: "width",
        param: "crop[]",
        label: "Width",
        value: "160",
        placeholder: "160",
        inputMode: "numeric",
      },
      {
        key: "height",
        param: "crop[]",
        label: "Height",
        value: "160",
        placeholder: "160",
        inputMode: "numeric",
      },
    ],
  },
  {
    groupKey: "crop-trim",
    key: "crop-center",
    controls: [
      {
        key: "crop",
        param: "crop",
        label: "Crop",
        value: "center",
        placeholder: "center",
        inputMode: "text",
      },
    ],
  },
  {
    groupKey: "crop-trim",
    key: "crop-smart",
    controls: [
      {
        key: "crop",
        param: "crop",
        label: "Crop",
        value: "smart",
        placeholder: "smart",
        inputMode: "text",
      },
      {
        key: "width",
        param: "resize[width]",
        label: "Width",
        value: "320",
        placeholder: "320",
        inputMode: "numeric",
      },
      {
        key: "height",
        param: "resize[height]",
        label: "Height",
        value: "320",
        placeholder: "320",
        inputMode: "numeric",
      },
    ],
  },
  {
    groupKey: "crop-trim",
    key: "trim-borders",
    controls: [
      {
        key: "trim",
        param: "trim",
        label: "Trim",
        value: "true",
        placeholder: "true",
        inputMode: "text",
      },
    ],
  },

  // ==========================================
  // NHÓM 4: HƯỚNG VÀ GÓC XOAY (ORIENTATION)
  // ==========================================
  {
    groupKey: "orientation",
    key: "autorot-exif",
    controls: [
      {
        key: "autorot",
        param: "autorot",
        label: "Autorotate",
        value: "true",
        placeholder: "true",
        inputMode: "text",
      },
    ],
  },
  {
    groupKey: "orientation",
    key: "rotate-jpg",
    controls: [
      {
        key: "rotate",
        param: "rotate",
        label: "Angle",
        value: "90",
        placeholder: "90",
        inputMode: "numeric",
      },
      {
        key: "to-format",
        param: "toFormat",
        label: "Format",
        value: "jpg",
        placeholder: "jpg",
        inputMode: "text",
      },
    ],
  },
  {
    groupKey: "orientation",
    key: "flip-horizontal",
    controls: [
      {
        key: "flip",
        param: "flip",
        label: "Flip",
        value: "horizontal",
        placeholder: "horizontal",
        inputMode: "text",
      },
    ],
  },
  {
    groupKey: "orientation",
    key: "flip-vertical",
    controls: [
      {
        key: "flip",
        param: "flip",
        label: "Flip",
        value: "vertical",
        placeholder: "vertical",
        inputMode: "text",
      },
    ],
  },

  // ==========================================
  // NHÓM 5: ĐỊNH DẠNG, CHẤT LƯỢNG & NỀN (FORMAT & BACKGROUND)
  // ==========================================
  {
    groupKey: "format-background",
    key: "webp",
    controls: [
      {
        key: "to-format",
        param: "toFormat",
        label: "Format",
        value: "webp",
        placeholder: "webp",
        inputMode: "text",
      },
    ],
  },
  {
    groupKey: "format-background",
    key: "png-output",
    controls: [
      {
        key: "to-format",
        param: "toFormat",
        label: "Format",
        value: "png",
        placeholder: "png",
        inputMode: "text",
      },
    ],
  },
  {
    groupKey: "format-background",
    key: "heif-output",
    controls: [
      {
        key: "to-format",
        param: "toFormat",
        label: "Format",
        value: "heif",
        placeholder: "heif",
        inputMode: "text",
      },
    ],
  },
  {
    groupKey: "format-background",
    key: "jpg-quality-80",
    controls: [
      {
        key: "to-format",
        param: "toFormat",
        label: "Format",
        value: "jpg",
        placeholder: "jpg",
        inputMode: "text",
      },
      {
        key: "quality",
        param: "quality",
        label: "Quality",
        value: "80",
        placeholder: "80",
        inputMode: "numeric",
      },
    ],
  },
  {
    groupKey: "format-background",
    key: "webp-quality-60",
    controls: [
      {
        key: "to-format",
        param: "toFormat",
        label: "Format",
        value: "webp",
        placeholder: "webp",
        inputMode: "text",
      },
      {
        key: "quality",
        param: "quality",
        label: "Quality",
        value: "60",
        placeholder: "60",
        inputMode: "numeric",
      },
    ],
  },
  {
    groupKey: "format-background",
    key: "flatten-white-bg",
    controls: [
      {
        key: "flatten",
        param: "flatten",
        label: "Flatten",
        value: "true",
        placeholder: "true",
        inputMode: "text",
      },
      {
        key: "background",
        param: "background",
        label: "Background",
        value: "255,255,255",
        placeholder: "255,255,255",
        inputMode: "text",
      },
    ],
  },
  {
    groupKey: "format-background",
    key: "flatten-black-bg",
    controls: [
      {
        key: "flatten",
        param: "flatten",
        label: "Flatten",
        value: "true",
        placeholder: "true",
        inputMode: "text",
      },
      {
        key: "background",
        param: "background",
        label: "Background",
        value: "0,0,0",
        placeholder: "0,0,0",
        inputMode: "text",
      },
    ],
  },
  {
    groupKey: "format-background",
    key: "background-hex",
    controls: [
      {
        key: "background",
        param: "background",
        label: "Background",
        value: "#ffffff",
        placeholder: "#ffffff",
        inputMode: "text",
      },
    ],
  },

  // ==========================================
  // NHÓM 6: BỘ LỌC MÀU SẮC & NGHỆ THUẬT (FILTERS)
  // ==========================================
  {
    groupKey: "filters",
    key: "gaussblur",
    controls: [
      {
        key: "gaussblur",
        param: "gaussblur",
        label: "Sigma",
        value: "2",
        placeholder: "2",
        inputMode: "decimal",
      },
    ],
  },
  {
    groupKey: "filters",
    key: "sharpen",
    controls: [
      {
        key: "sigma",
        param: "sharpen[sigma]",
        label: "Sigma",
        value: "2",
        placeholder: "2",
        inputMode: "decimal",
      },
    ],
  },
  {
    groupKey: "filters",
    key: "grayscale",
    controls: [
      {
        key: "colourspace",
        param: "colourspace",
        label: "Colourspace",
        value: "b-w",
        placeholder: "b-w",
        inputMode: "text",
      },
    ],
  },
  {
    groupKey: "filters",
    key: "invert-colors",
    controls: [
      {
        key: "invert",
        param: "invert",
        label: "Invert",
        value: "true",
        placeholder: "true",
        inputMode: "text",
      },
    ],
  },
  {
    groupKey: "filters",
    key: "edge-detection",
    controls: [
      {
        key: "sobel",
        param: "sobel",
        label: "Sobel Edge",
        value: "true",
        placeholder: "true",
        inputMode: "text",
      },
    ],
  },
  {
    groupKey: "filters",
    key: "median-noise-reduction",
    controls: [
      {
        key: "median",
        param: "median",
        label: "Median",
        value: "3",
        placeholder: "3",
        inputMode: "numeric",
      },
    ],
  },
  {
    groupKey: "filters",
    key: "brightness-contrast",
    controls: [
      {
        key: "brightness",
        param: "brightness",
        label: "Brightness",
        value: "1.2",
        placeholder: "1.2",
        inputMode: "decimal",
      },
      {
        key: "contrast",
        param: "contrast",
        label: "Contrast",
        value: "0.9",
        placeholder: "0.9",
        inputMode: "decimal",
      },
    ],
  },

  // ==========================================
  // NHÓM 7: COMBO PHỐI HỢP & WATERMARK (COMBOS & OVERLAYS)
  // ==========================================
  {
    groupKey: "combos-overlays",
    key: "combo-avatar",
    controls: [
      {
        key: "width",
        param: "resize[width]",
        label: "Width",
        value: "200",
        placeholder: "200",
        inputMode: "numeric",
      },
      {
        key: "height",
        param: "resize[height]",
        label: "Height",
        value: "200",
        placeholder: "200",
        inputMode: "numeric",
      },
      {
        key: "crop",
        param: "crop",
        label: "Crop",
        value: "smart",
        placeholder: "smart",
        inputMode: "text",
      },
      {
        key: "blur",
        param: "gaussblur",
        label: "Blur Sigma",
        value: "1.5",
        placeholder: "1.5",
        inputMode: "decimal",
      },
      {
        key: "format",
        param: "toFormat",
        label: "Format",
        value: "webp",
        placeholder: "webp",
        inputMode: "text",
      },
    ],
  },
  {
    groupKey: "combos-overlays",
    key: "combo-art-dark",
    controls: [
      {
        key: "grayscale",
        param: "colourspace",
        label: "Colourspace",
        value: "b-w",
        placeholder: "b-w",
        inputMode: "text",
      },
      {
        key: "invert",
        param: "invert",
        label: "Invert",
        value: "true",
        placeholder: "true",
        inputMode: "text",
      },
      {
        key: "sharpen",
        param: "sharpen[sigma]",
        label: "Sharpen",
        value: "1.2",
        placeholder: "1.2",
        inputMode: "decimal",
      },
    ],
  },
  {
    groupKey: "combos-overlays",
    key: "rotate-then-crop",
    controls: [
      {
        key: "rotate",
        param: "rotate",
        label: "Angle",
        value: "90",
        placeholder: "90",
        inputMode: "numeric",
      },
      {
        key: "left",
        param: "crop[]",
        label: "Left",
        value: "0",
        placeholder: "0",
        inputMode: "numeric",
      },
      {
        key: "top",
        param: "crop[]",
        label: "Top",
        value: "0",
        placeholder: "0",
        inputMode: "numeric",
      },
      {
        key: "width",
        param: "crop[]",
        label: "Width",
        value: "160",
        placeholder: "160",
        inputMode: "numeric",
      },
      {
        key: "height",
        param: "crop[]",
        label: "Height",
        value: "160",
        placeholder: "160",
        inputMode: "numeric",
      },
    ],
  },
  {
    groupKey: "combos-overlays",
    key: "watermark",
    controls: [
      {
        key: "watermark",
        param: "watermark",
        label: "Watermark",
        value: "© MySite",
        placeholder: "© MySite",
        inputMode: "text",
      },
    ],
  },
  {
    groupKey: "combos-overlays",
    key: "metadata",
    controls: [
      {
        key: "metadata",
        param: "metadata",
        label: "Metadata",
        value: "true",
        placeholder: "true",
        inputMode: "text",
      },
    ],
  },

  // ==========================================
  // NHÓM 8: KIỂM THỬ NGOẠI LỆ & LỖI (NEGATIVE & BOUNDARIES)
  // ==========================================
  {
    groupKey: "negative-boundaries",
    key: "invalid-format",
    controls: [
      {
        key: "to-format",
        param: "toFormat",
        label: "Format",
        value: "invalid",
        placeholder: "invalid",
        inputMode: "text",
      },
    ],
  },
  {
    groupKey: "negative-boundaries",
    key: "invalid-quality-high",
    controls: [
      {
        key: "quality",
        param: "quality",
        label: "Quality",
        value: "150",
        placeholder: "150",
        inputMode: "numeric",
      },
    ],
  },
  {
    groupKey: "negative-boundaries",
    key: "invalid-resize-width-height-too-large",
    controls: [
      {
        key: "width",
        param: "resize[width]",
        label: "Width",
        value: "99999",
        placeholder: "99999",
        inputMode: "numeric",
      },
      {
        key: "height",
        param: "resize[height]",
        label: "Height",
        value: "99999",
        placeholder: "99999",
        inputMode: "numeric",
      },
    ],
  },
  {
    groupKey: "negative-boundaries",
    key: "invalid-resize-scale-too-large",
    controls: [
      {
        key: "resize",
        param: "resize",
        label: "Scale",
        value: "99999",
        placeholder: "99999",
        inputMode: "numeric",
      },
    ],
  },
];

// ==========================================
// LOGIC VUE APP
// ==========================================
createApp({
  data() {
    const defaultBase =
      window.location.origin && /^https?:/i.test(window.location.origin)
        ? window.location.origin
        : "http://localhost:4000";
    const isLocalHost = /^(localhost|127\.0\.0\.1)$/i.test(
      window.location.hostname,
    );
    const defaultSourceUrl = isLocalHost
      ? "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Fronalpstock_big.jpg/960px-Fronalpstock_big.jpg"
      : `${defaultBase}/apple-touch-icon.png`;

    return {
      ui: UI,
      i18n: I18N, // Có thể dùng trong template nếu cần
      apiBase: defaultBase,
      isLocalHost,
      credentials: {
        email: "",
        password: "",
      },
      sourceUrl: defaultSourceUrl,
      token: "",
      userEmail: "",
      authMessage: "",
      authError: "",
      renderError: "",
      isLoggingIn: false,
      isRendering: false,
      activeGroupKey: "",
      items: [],
      plannedCount: 0,
    };
  },

  computed: {
    isAuthenticated() {
      return Boolean(this.token);
    },

    canRender() {
      return (
        this.isAuthenticated &&
        Boolean(this.cleanSourceUrl) &&
        Boolean(this.cleanApiBase)
      );
    },

    cleanApiBase() {
      return this.apiBase.trim().replace(/\/+$/, "");
    },

    cleanSourceUrl() {
      return this.sourceUrl.trim();
    },

    completedCount() {
      return this.items.filter(
        (item) => item.status === "done" || item.status === "error",
      ).length;
    },

    progressPercent() {
      const total = this.items.length || this.plannedCount;

      if (!total) {
        return 0;
      }

      return Math.round((this.completedCount / total) * 100);
    },

    scenarioGroups() {
      const groupedItems = new Map();

      this.items.forEach((item) => {
        const bucket = groupedItems.get(item.groupKey) || [];
        bucket.push(item);
        groupedItems.set(item.groupKey, bucket);
      });

      return SCENARIO_GROUPS.map((group) => {
        const items = groupedItems.get(group.key) || [];
        const completedCount = items.filter(
          (item) => item.status === "done" || item.status === "error",
        ).length;

        return {
          ...group,
          items,
          completedCount,
        };
      }).filter((group) => group.items.length > 0);
    },

    tokenPreview() {
      const raw = this.token.replace(/^Bearer\s+/i, "");

      if (!raw) {
        return "";
      }

      if (raw.length <= 24) {
        return `Bearer ${raw}`;
      }

      return `Bearer ${raw.slice(0, 16)}...${raw.slice(-10)}`;
    },
  },

  methods: {
    statusLabel(status) {
      return I18N.status[status] || status;
    },

    statusBadgeClass(status) {
      const variants = {
        queued: "bg-stone-900/8 text-stone-600",
        loading: "bg-amber-700/12 text-amber-900",
        done: "bg-emerald-700/12 text-emerald-900",
        error: "bg-rose-700/12 text-rose-900",
      };

      return `shrink-0 rounded-full px-3 py-1 text-[0.75rem] font-extrabold uppercase tracking-[0.05em] ${variants[status] || variants.queued}`;
    },

    buildScenarios() {
      return scenarioConfigs.map((config, index) => {
        const langData = I18N.scenarios[config.key] || {
          label: config.key,
          note: "",
        };
        const item = {
          id: `${Date.now()}-${index}`,
          groupKey: config.groupKey,
          key: config.key,
          label: langData.label,
          note: langData.note,
          controls: (config.controls || []).map((control) => ({ ...control })),
          requestUrl: "",
          status: "queued",
          message: "",
          previewUrl: "",
          objectUrl: "",
          imageWidth: null,
          imageHeight: null,
          previewWarning: false,
          warningMessage: "",
          durationMs: null,
          bytes: 0,
          contentType: "",
        };

        item.requestUrl = this.buildRequestUrl(item);
        return item;
      });
    },

    buildRequestUrl(item) {
      const params = [`url=${encodeURIComponent(this.cleanSourceUrl)}`];

      (item.controls || []).forEach((control) => {
        const value = control.value.trim();

        if (!value) {
          return;
        }

        if (control.rawQuery) {
          const rawParams = new URLSearchParams(value.replace(/^[?&]+/, ""));

          for (const [key, rawValue] of rawParams.entries()) {
            params.push(`${key}=${encodeURIComponent(rawValue)}`);
          }

          return;
        }

        params.push(`${control.param}=${encodeURIComponent(value)}`);
      });

      return `${this.cleanApiBase}/image?${params.join("&")}`;
    },

    parseDimensionHeader(value) {
      const parsed = Number.parseInt(value || "", 10);

      if (!Number.isFinite(parsed) || parsed <= 0) {
        return null;
      }

      return parsed;
    },

    readRenderedDimensions(response) {
      return {
        width: this.parseDimensionHeader(response.headers.get("X-Image-Width")),
        height: this.parseDimensionHeader(response.headers.get("X-Image-Height")),
      };
    },

    formatDimensions(item) {
      if (!item.imageWidth || !item.imageHeight) {
        return "-";
      }

      return `${item.imageWidth} x ${item.imageHeight}`;
    },

    groupActionLabel(group) {
      if (this.activeGroupKey === group.key && this.isRendering) {
        return "Đang chạy nhóm...";
      }

      return group.completedCount ? "Chạy lại nhóm" : "Chạy nhóm này";
    },

    resetItemState(item, message = "") {
      if (item.objectUrl) {
        URL.revokeObjectURL(item.objectUrl);
      }

      item.status = "queued";
      item.message = message;
      item.previewUrl = "";
      item.objectUrl = "";
      item.imageWidth = null;
      item.imageHeight = null;
      item.previewWarning = false;
      item.warningMessage = "";
      item.durationMs = null;
      item.bytes = 0;
      item.contentType = "";
    },

    prepareItemForRender(item) {
      this.resetItemState(item);
      item.requestUrl = this.buildRequestUrl(item);
    },

    handleControlInput(item) {
      item.requestUrl = this.buildRequestUrl(item);
      this.resetItemState(item, I18N.render.parametersUpdated);
    },

    async signIn() {
      this.authMessage = "";
      this.authError = "";
      this.renderError = "";

      if (
        !this.cleanApiBase ||
        !this.credentials.email ||
        !this.credentials.password
      ) {
        this.authError = I18N.auth.missingFields;
        return;
      }

      this.isLoggingIn = true;

      try {
        const response = await fetch(`${this.cleanApiBase}/users/sign_in`, {
          method: "POST",
          headers: {
            Accept: "application/json",
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            user: {
              email: this.credentials.email,
              password: this.credentials.password,
            },
          }),
        });

        const payload = await this.readPayload(response);
        const authHeader =
          response.headers.get("Authorization") ||
          response.headers.get("authorization");

        if (!response.ok) {
          throw new Error(
            payload.error ||
              payload.message ||
              `${I18N.auth.loginFailed} (${response.status})`,
          );
        }

        if (!authHeader) {
          throw new Error(I18N.auth.missingAuthHeader);
        }

        this.token = authHeader.startsWith("Bearer ")
          ? authHeader
          : `Bearer ${authHeader}`;
        this.userEmail = payload.email || this.credentials.email;
        this.authMessage = `${I18N.auth.loginSuccess} ${this.userEmail}`;
      } catch (error) {
        this.token = "";
        this.userEmail = "";
        this.authError = error.message || I18N.auth.defaultError;
      } finally {
        this.isLoggingIn = false;
      }
    },

    async signOut() {
      const currentToken = this.token;
      this.cleanupObjectUrls();
      this.items = [];
      this.renderError = "";
      this.authMessage = "";
      this.authError = "";
      this.token = "";
      this.userEmail = "";
      this.isRendering = false;
      this.activeGroupKey = "";
      this.plannedCount = 0;

      if (!currentToken || !this.cleanApiBase) {
        return;
      }

      try {
        await fetch(`${this.cleanApiBase}/users/sign_out`, {
          method: "DELETE",
          headers: {
            Accept: "application/json",
            Authorization: currentToken,
          },
        });
      } catch (_error) {}
    },

    clearRenderResults() {
      if (this.isRendering) {
        return;
      }

      this.cleanupObjectUrls();
      this.items = [];
      this.plannedCount = 0;
      this.activeGroupKey = "";
      this.renderError = "";
    },

    async delay(ms) {
      return new Promise((resolve) => setTimeout(resolve, ms));
    },

    async startRender() {
      this.renderError = "";

      if (!this.canRender) {
        this.renderError = I18N.render.missingPrerequisites;
        return;
      }

      if (!this.items.length) {
        this.items = this.buildScenarios();
      } else {
        this.items.forEach((item) => this.prepareItemForRender(item));
      }

      this.plannedCount = this.items.length;
      this.activeGroupKey = "";
    },

    async runGroup(groupKey) {
      this.renderError = "";

      if (!this.canRender) {
        this.renderError = I18N.render.missingPrerequisites;
        return;
      }

      if (!this.items.length) {
        this.items = this.buildScenarios();
        this.plannedCount = this.items.length;
      }

      const groupItems = this.items.filter((item) => item.groupKey === groupKey);

      if (!groupItems.length) {
        return;
      }

      this.isRendering = true;
      this.activeGroupKey = groupKey;

      try {
        groupItems.forEach((item) => this.prepareItemForRender(item));

        for (const item of groupItems) {
          await this.loadRenderItem(item);
        }
      } finally {
        this.isRendering = false;
        this.activeGroupKey = "";
      }
    },

    async renderItem(item) {
      this.renderError = "";

      if (!this.canRender) {
        this.renderError = I18N.render.missingPrerequisites;
        return;
      }

      this.isRendering = true;

      try {
        this.prepareItemForRender(item);
        await this.loadRenderItem(item);
      } finally {
        this.isRendering = false;
      }
    },

    async loadRenderItem(item) {
      item.requestUrl = this.buildRequestUrl(item);
      item.status = "loading";
      item.message = I18N.render.sendingRequest;
      const startedAt = performance.now();

      try {
        const response = await fetch(item.requestUrl, {
          method: "GET",
          headers: {
            Authorization: this.token,
          },
        });

        if (!response.ok) {
          const payload = await this.readPayload(response);
          throw new Error(
            payload.error ||
              payload.message ||
              `${I18N.render.renderFailed} (${response.status})`,
          );
        }

        const blob = await response.blob();
        const headerDimensions = this.readRenderedDimensions(response);
        const objectUrl = URL.createObjectURL(blob);

        item.objectUrl = objectUrl;
        item.bytes = blob.size;
        item.contentType =
          response.headers.get("content-type") || blob.type || "unknown";

        item.imageWidth = headerDimensions.width;
        item.imageHeight = headerDimensions.height;

        try {
          const previewMetadata = await this.waitForImageDecode(objectUrl);

          item.previewUrl = objectUrl;

          if (!item.imageWidth) {
            item.imageWidth = previewMetadata.width;
          }

          if (!item.imageHeight) {
            item.imageHeight = previewMetadata.height;
          }
        } catch (_decodeError) {
          item.previewUrl = "";
          item.previewWarning = true;
          item.warningMessage = I18N.render.previewUnavailable;
        }

        item.durationMs = Math.round(performance.now() - startedAt);
        item.status = "done";
        item.message = `${I18N.render.loadedIn} ${item.durationMs} ms.`;
      } catch (error) {
        if (item.objectUrl) {
          URL.revokeObjectURL(item.objectUrl);
          item.objectUrl = "";
        }

        item.previewUrl = "";
        item.durationMs = Math.round(performance.now() - startedAt);
        item.status = "error";
        item.message = error.message || I18N.render.loadErrorDefault;
      }
    },

    cleanupObjectUrls() {
      this.items.forEach((item) => {
        if (item.objectUrl) {
          URL.revokeObjectURL(item.objectUrl);
        }
      });
    },

    async readPayload(response) {
      const text = await response.text();

      if (!text) {
        return {};
      }

      try {
        return JSON.parse(text);
      } catch (_error) {
        return { message: text };
      }
    },

    waitForImageDecode(objectUrl) {
      return new Promise((resolve, reject) => {
        const image = new Image();
        image.onload = () => {
          resolve({
            width: image.naturalWidth || image.width,
            height: image.naturalHeight || image.height,
          });
        };
        image.onerror = () => reject(new Error(I18N.render.decodeError));
        image.src = objectUrl;
      });
    },

    humanBytes(bytes) {
      if (!Number.isFinite(bytes)) {
        return "-";
      }

      const units = ["B", "KB", "MB", "GB"];
      let value = bytes;
      let index = 0;

      while (value >= 1024 && index < units.length - 1) {
        value /= 1024;
        index += 1;
      }

      const fractionDigits = value < 10 && index > 0 ? 1 : 0;
      return `${value.toFixed(fractionDigits)} ${units[index]}`;
    },
  },

  mounted() {
    document.getElementById("app")?.classList.remove("hidden");
  },

  beforeUnmount() {
    this.cleanupObjectUrls();
  },
}).mount("#app");
