import fs from 'fs';
import path from 'path';

const ALLOWED_SCRIPTS = [
    'farm_script'
];

export default function handler(request, response) {
  const userAgent = request.headers['user-agent'];
  const { name } = request.query;

  if (!ALLOWED_SCRIPTS.includes(name)) {
    return response.status(404).send('// 404: Script tidak ditemukan.');
  }

  if (userAgent && userAgent.includes('Roblox')) {
    try {
      const filePath = path.join(process.cwd(), '_internal', 'scripts', `${name}.lua`);
      if (!fs.existsSync(filePath)) {
          return response.status(404).send(`// 404: Script '${name}' tidak ada di server.`);
      }
      const scriptContent = fs.readFileSync(filePath, 'utf-8');
      response.setHeader('Content-Type', 'text/plain; charset=utf-8');
      response.status(200).send(scriptContent);
    } catch (error) {
      console.error(`Error saat membaca script ${name}.lua:`, error);
      response.status(500).send('// 500: Terjadi kesalahan di server.');
    }
  } else {
    try {
      const forbiddenPagePath = path.join(process.cwd(), 'forbidden.html');
      const forbiddenPageContent = fs.readFileSync(forbiddenPagePath, 'utf-8');
      response.setHeader('Content-Type', 'text/html; charset=utf-8');
      response.status(403).send(forbiddenPageContent);
    } catch (error) {
       response.status(500).send('<h1>Error 500</h1><p>Gagal memuat halaman akses ditolak.</p>');
    }
  }
}
