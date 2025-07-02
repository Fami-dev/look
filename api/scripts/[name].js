// File: api/scripts/[name].js

import fs from 'fs';
import path from 'path';

// Daftar script yang diizinkan untuk keamanan
const ALLOWED_SCRIPTS = ['farm_script', 'pvp_helper'];

export default function handler(request, response) {
  const userAgent = request.headers['user-agent'];

  // 1. Dapatkan nama script dari URL (misal: 'farm_script' dari /api/scripts/farm_script)
  const { name } = request.query;

  // 2. Validasi nama script untuk mencegah serangan (Path Traversal)
  if (!ALLOWED_SCRIPTS.includes(name)) {
    return response.status(404).send('// Script tidak ditemukan.');
  }

  // 3. Logika User-Agent tetap sama
  if (userAgent && userAgent.includes('Roblox')) {
    try {
      // Bentuk path file secara dinamis dan aman
      const filePath = path.join(process.cwd(), '_internal', 'scripts', `${name}.lua`);
      
      // Periksa apakah file benar-benar ada sebelum dibaca
      if (!fs.existsSync(filePath)) {
          return response.status(404).send('// Script tidak ditemukan di server.');
      }

      const scriptContent = fs.readFileSync(filePath, 'utf-8');
      response.setHeader('Content-Type', 'text/plain; charset=utf-8');
      response.status(200).send(scriptContent);
    } catch (error) {
      console.error(`Error reading script ${name}.lua:`, error);
      response.status(500).send('// Terjadi kesalahan di server.');
    }
  } else {
    // Tampilkan halaman forbidden yang sama
    try {
      const forbiddenPagePath = path.join(process.cwd(), 'public', 'forbidden.html');
      const forbiddenPageContent = fs.readFileSync(forbiddenPagePath, 'utf-8');
      response.setHeader('Content-Type', 'text/html; charset=utf-8');
      response.status(403).send(forbiddenPageContent);
    } catch (error) {
       response.status(500).send('<h1>Error 500</h1><p>Could not load page.</p>');
    }
  }
}
