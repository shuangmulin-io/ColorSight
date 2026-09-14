<div align="center">

# ColorSight 👁️🎨
### Medical-Grade Color Vision Deficiency (CVD) Screening & Everyday Color Assistant

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![PWA](https://img.shields.io/badge/PWA-100%25%20Offline-10B981?logo=pwa&logoColor=white)](https://web.dev/progressive-web-apps/)
[![Security](https://img.shields.io/badge/Security-Strict%20CSP%20%7C%20Anti--Framing-38BDF8?logo=shield)](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
[![Tests](https://img.shields.io/badge/Tests-25%2F25%20Passing-10B981?logo=checkmarx)](https://flutter.dev/docs/testing)
[![License](https://img.shields.io/badge/License-MIT-gray.svg)](LICENSE)

*A zero-dependency, privacy-first cross-platform application providing scientifically modeled Ishihara screening tests and an assistive real-time photo color identifier.*

---

[Key Capabilities](#-key-capabilities) • [Clinical Methodology](#-clinical-methodology) • [Security & Privacy](#-security--privacy-posture) • [Architecture](#-architecture) • [Getting Started](#-getting-started) • [Testing](#-automated-testing--qa)

</div>

---

## 🌟 Key Capabilities

### 1. Procedural Ishihara Screening Engine
- **Procedural Dot Generation:** Algorithmic pseudoisochromatic plate rendering utilizing Poisson disc distribution and CIELAB $\Delta E$ perceptual color contrast models.
- **Dynamic Shuffling:** Plate 1 remains constant as the clinical demonstration plate, while subsequent diagnostic plates are randomized per session to eliminate plate memorization.
- **3 Selectable Clinical Batteries:**
  - **Quick Check (6 Plates):** High-speed occupational / pre-employment triage (< 1 minute).
  - **Standard Clinical (14 Plates):** Standardized screening protocol for red-green and blue-yellow deficiencies.
  - **Comprehensive Diagnostic (24 Plates):** Complete clinical battery for in-depth qualitative classification and severity stratification.

### 2. Clinical Diagnostic Scoring & Reports
- **Automated Differential Scoring:** Diagnoses **Normal Trichromacy**, **Protan** (Red-Weak / Red-Blind), **Deutan** (Green-Weak / Green-Blind), and **Tritan** (Blue-Yellow) with Mild / Moderate / Severe classification.
- **Auto-Paginating PDF Reports:** Generates standardized, multi-page vector PDF screening summaries with customizable patient/subject names, plate-by-plate audit tables, and spectrum perception comparisons.
- **Native "Save As..." File System Access:** Integrated Chromium File System Access API (`showSaveFilePicker`) prompting a native Windows / OS file save destination dialog with smart suggested filenames (`ColorSight-Report-[Name]-[Date].pdf`).

### 3. Longitudinal Test History Viewer
- **Persistent Local History:** Retains up to 50 past screening sessions locally in browser/device storage.
- **Historical Report Re-Export:** Instantly view past diagnostic outcomes or re-generate PDF documentation without repeating tests.
- **Privacy-First Clear History:** On-device database wipe with a safety confirmation dialog.

### 4. Desktop & Laptop Keyboard Navigation
- **Full Physical Keyboard Support:** Type digits `0`–`9` (number row and numeric keypad), submit answers with `Enter`, delete with `Backspace`, clear with `Escape`/`Delete`, and record *"Nothing / Unseen"* with `Space` or `N`.
- **Responsive Visual Cues:** Dynamic shortcut banner and keyboard badges (`[Space]`, `[Enter]`) optimized for desktop display widths without layout overflow.

### 5. Everyday Photo Color Identifier
- **5×5 Box Noise Filtering:** Eliminates digital sensor grain and optical noise by computing local kernel averages in RGB color space.
- **Extensive Color Taxonomy:** Maps sampled pixels to plain-language color names with an optional "Specific / Nuances" toggle (e.g., *Emerald Green* vs. *Green*).
- **Personalized Confusion Warnings:** Cross-references detected colors against the user's screening profile to proactively flag problematic color confusion pairs (e.g. warning a Deuteranope that a sampled olive color is actually green).
- **One-Tap Clipboard Copy:** Copy color name, hex code, and RGB values (e.g., `Forest Green (#2E8B57) • RGB(46, 139, 87)`) with an interactive tap target and floating confirmation toast.

---

## 🔬 Clinical Methodology

ColorSight implements established color science and psychophysical principles:

1. **Brettel/Viénot Dichromacy Simulation:** Procedurally generated plates are validated by automated unit tests (`test/ishihara_qa_test.dart`) that simulate dichromatic perception via matrix projection in LMS cone space:
   $$\begin{bmatrix} L \\ M \\ S \end{bmatrix} = \mathbf{M}_{\text{sRGB}\to\text{LMS}} \begin{bmatrix} R \\ G \\ B \end{bmatrix}$$
2. **Display Calibration Protocol:** Enforces pre-test checks for ambient glare, screen brightness (100%), natural color profile (disabling "Vivid" mode), and blue-light filters (Night Shift / True Tone).
3. **CIELAB Color Uniformity:** Plate foreground numerals and background distractor dots are calibrated using CIE $L^*a^*b^*$ color space to ensure uniform luminance ($L^*$), making the hidden figures distinguishable *solely* by hue chromaticity ($\Delta a^*, \Delta b^*$).

---

## 🛡️ Security & Privacy Posture

ColorSight is engineered with a strict **zero-trust, offline-first security model**:

- **100% Offline & Private:** Zero analytics, zero telemetries, zero third-party tracking scripts, and zero cloud API dependencies. All computation, scoring, and PDF generation occur in-memory on the client device.
- **Strict Content Security Policy (CSP):**
  ```html
  default-src 'self';
  script-src 'self' 'wasm-unsafe-eval' https://www.gstatic.com;
  style-src 'self' 'unsafe-inline';
  font-src 'self' data: https://fonts.gstatic.com;
  img-src 'self' blob: data:;
  connect-src 'self' https://fonts.gstatic.com;
  ```
- **Host-Level Clickjacking Protection:** Pre-configured HTTP response headers (`web/_headers` and `firebase.json`):
  - `Content-Security-Policy: frame-ancestors 'none';`
  - `X-Frame-Options: DENY`
  - `X-Content-Type-Options: nosniff`
  - `Referrer-Policy: no-referrer`
- **Memory-Conscious Native Downscaling:** User-selected camera photos are downscaled via platform-native pipelines (`maxWidth: 2048`, `maxHeight: 2048`) prior to decoding, preventing out-of-memory crashes on mobile browsers.
- **Bounded Storage Retention:** Implements a strict 50-item FIFO retention cap in `TestHistoryRepository`, preventing unbounded JSON growth and localStorage quota exhaustion.
- **Bundled Typography:** Bundles local Roboto TTF font assets (`regular`, `medium`, `bold`), eliminating external network requests and preventing CanvasKit font-blocking visual glitches.

---

## 🏗️ Architecture

```text
ColorSight/
├── lib/
│   ├── core/
│   │   ├── theme/          # AppTheme, AppColors design system
│   │   └── utils/          # CIELAB color math & Brettel/Viénot CVD simulator
│   ├── features/
│   │   ├── color_id/       # Photo Color Identifier & ColorNamer engine
│   │   ├── home/           # Home dashboard & mode navigation
│   │   ├── reports/        # MultiPage PDF report builder & FileSaverService
│   │   ├── results/        # Results screen, audit breakdown & test history
│   │   └── test/           # Ishihara engine, battery generator & scoring service
│   └── main.dart           # Application entry point & theme initialization
├── test/                   # Automated unit, widget, and QA test suites
├── web/                    # PWA service worker (v22), manifest, strict CSP shell
├── assets/                 # Bundled offline TTF fonts & brand icons
└── pubspec.yaml            # Project dependencies & asset declarations
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (`>= 3.24.0`)
- [Dart SDK](https://dart.dev/get-dart) (`>= 3.5.0`)
- Google Chrome, Edge, or Safari for web deployment

### 1. Clone the Repository
```bash
git clone https://github.com/shuangmulin-io/ColorSight.git
cd ColorSight
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run Locally in Development Mode
```bash
flutter run -d chrome
```

### 4. Build Production Web (PWA) Release
```bash
flutter build web --release
```
To serve the production bundle locally:
```bash
python -m http.server 8080 --directory build/web
```
Navigate to `http://localhost:8080` in your web browser.

---

## 🧪 Automated Testing & QA

ColorSight includes comprehensive automated unit and widget test coverage across all core features:

```bash
# Run all automated tests
flutter test

# Run static analysis and lint checks
flutter analyze
```

### Test Coverage Highlights
- `test/ishihara_qa_test.dart`: Brettel/Viénot dichromacy contrast validation, plate shuffling invariance, and battery length integrity.
- `test/scoring_test.dart`: Diagnostic accuracy across Protan, Deutan, and Tritan response patterns.
- `test/keyboard_shortcuts_test.dart`: Desktop keyboard inputs, backspace deletion, digit bounds, and Enter/Space submissions.
- `test/pdf_export_test.dart`: Multi-page layout pagination, table layout bounds, and character sanitization.
- `test/test_history_test.dart`: FIFO retention capping, persistent storage serialization, and clear history actions.
- `test/photo_color_picker_test.dart`: Color naming, nuance toggles, and clipboard copy operations.

---

## ⚖️ Clinical Disclaimer

*ColorSight is designed as an accessible, high-precision informational and screening tool. While based on standardized pseudoisochromatic principles (Ishihara/Richmond batteries), digital screenings depend on individual display hardware color calibration, ambient lighting, and screen reflections. ColorSight does not provide a formal medical diagnosis. For official occupational certification or medical evaluation, consult a licensed optometrist or ophthalmologist.*

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
