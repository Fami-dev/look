// File: api/script.js

// Import modul 'fs' untuk membaca file dan 'path' untuk menangani path file
import fs from 'fs';
import path from 'path';

export default function handler(request, response) {
  // 1. Dapatkan header User-Agent dari permintaan yang masuk
  const userAgent = request.headers['user-agent'];

  // 2. Periksa apakah User-Agent mengandung kata 'Roblox'
  // Ini adalah cara paling andal untuk mengidentifikasi permintaan dari game
  if (userAgent && userAgent.includes('Roblox')) {
    // JIKA DARI ROBLOX:
    try {
      // Tentukan path absolut ke file script rahasia Anda
      const filePath = path.join(process.cwd(), 'public', '_internal_script.lua');
      
      // Baca konten file script
      const scriptContent = fs.readFileSync(filePath, 'utf-8');
      
      // Kirim konten script sebagai teks biasa dengan status 200 OK
      response.setHeader('Content-Type', 'text/plain; charset=utf-8');
      response.status(200).send(scriptContent);

    } catch (error) {
      // Jika terjadi error saat membaca file, kirim pesan error
      response.status(500).send('Error: Could not read the script file.');
    }
  } else {
    // JIKA BUKAN DARI ROBLOX (misalnya dari browser):
    try {
      // Tentukan path ke halaman 'Akses Ditolak'
      const forbiddenPagePath = path.join(process.cwd(), 'public', 'forbidden.html');

      // Baca konten halaman HTML
      const forbiddenPageContent = fs.readFileSync(forbiddenPagePath, 'utf-8');

      // Kirim halaman HTML dengan status 403 Forbidden
      response.setHeader('Content-Type', 'text/html; charset=utf-8');
      response.status(403).send(forbiddenPageContent);

    } catch (error) {
       // Jika terjadi error, kirim pesan error sederhana
      response.status(500).send('Error: Could not load forbidden page.');
    }
  }
}
