/**
 * Script cập nhật nhanh bộ ngôn ngữ cho tất cả file trong
 * assets/translations/generated.
 *
 * Mục tiêu hiện tại: chỉ cập nhật 2 key:
 *   - onboarding-title-1
 *   - onboarding-info-1
 * Nguồn: vi.json, dịch sang các ngôn ngữ khác.
 *
 * Cài đặt: npm install @vitalets/google-translate-api
 */

const fs = require('fs');
const path = require('path');
const translateModule = require('@vitalets/google-translate-api');
const translate =
  translateModule.default || translateModule.translate || translateModule;

const CONFIG = {
  translationsDir: path.join(__dirname, 'assets', 'translations', 'generated'),
  sourceFile: 'vi.json',
  fallbackEnFile: 'en.json',
  sourceLang: 'vi',
  keys: ['onboarding-title-1', 'onboarding-info-1'],
  backup: true,
  delayMs: 400,
  langOverride: {
    'zh-Hant': 'zh-TW',
    'pt-PT': 'pt',
    fil: 'tl',
    no: 'nb'
  },
  skipFiles: new Set(['none.json', 'kxd.json'])
};

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

function getLangCode(fileName) {
  const base = path.basename(fileName, '.json');
  return CONFIG.langOverride[base] || base;
}

function listFiles() {
  return fs
    .readdirSync(CONFIG.translationsDir)
    .filter((f) => f.endsWith('.json'))
    .filter((f) => !CONFIG.skipFiles.has(f));
}

function readJson(fp) {
  return JSON.parse(fs.readFileSync(fp, 'utf8'));
}

function writeJson(fp, data) {
  fs.writeFileSync(fp, JSON.stringify(data, null, 2), 'utf8');
}

function backup(fp) {
  const dest = `${fp}.bak.${Date.now()}`;
  fs.copyFileSync(fp, dest);
  return dest;
}

async function translateText(text, target, fallbackText) {
  if (target === CONFIG.sourceLang) return text;
  if (target === 'en') return fallbackText || text;
  try {
    const res = await translate(text, { from: CONFIG.sourceLang, to: target });
    return res.text;
  } catch (e) {
    console.error(`⚠️  Lỗi dịch (${target}): ${e.message}`);
    return fallbackText || text;
  }
}

async function main() {
  console.log('🚀 Bắt đầu cập nhật 2 key onboarding từ vi.json');
  const files = listFiles();
  const sourcePath = path.join(CONFIG.translationsDir, CONFIG.sourceFile);
  const enPath = path.join(CONFIG.translationsDir, CONFIG.fallbackEnFile);
  if (!fs.existsSync(sourcePath)) {
    console.error(`❌ Không tìm thấy file nguồn: ${sourcePath}`);
    process.exit(1);
  }
  if (!fs.existsSync(enPath)) {
    console.error(`❌ Không tìm thấy file fallback tiếng Anh: ${enPath}`);
    process.exit(1);
  }

  const sourceData = readJson(sourcePath);
  const enData = readJson(enPath);
  const payload = {};
  for (const k of CONFIG.keys) {
    if (!(k in sourceData)) {
      console.error(`❌ Thiếu key "${k}" trong ${CONFIG.sourceFile}`);
      process.exit(1);
    }
    payload[k] = sourceData[k];
  }

  for (const file of files) {
    const filePath = path.join(CONFIG.translationsDir, file);
    const lang = getLangCode(file);
    console.log(`\n📄 ${file} (${lang})`);

    if (CONFIG.backup) {
      const b = backup(filePath);
      console.log(`   💾 Backup: ${b}`);
    }

    const data = readJson(filePath);
    let updated = 0;
    for (const [key, text] of Object.entries(payload)) {
      const fallbackText = enData[key] || text;
      const translated = await translateText(text, lang, fallbackText);
      data[key] = translated;
      updated++;
      console.log(`   ✅ ${key}: ${translated}`);
      await sleep(CONFIG.delayMs);
    }
    writeJson(filePath, data);
    console.log(`   ✨ Đã cập nhật ${updated} key`);
  }

  console.log('\n✅ Hoàn tất');
}

main().catch((err) => {
  console.error('❌ Lỗi:', err);
  process.exit(1);
});