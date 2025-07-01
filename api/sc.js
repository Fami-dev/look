import { promises as fs } from 'fs';
import path from 'path';

export default async function handler(request, response) {
    // Dapatkan User-Agent dari header
    const userAgent = request.headers['user-agent'] || '';

    // Periksa apakah ini executor Roblox
    if (userAgent.includes('Roblox')) {
        try {
            // Jika YA: Baca file sc.lua dari root direktori proyek
            const filePath = path.join(process.cwd(), 'sc.lua');
            const scriptContent = await fs.readFile(filePath, 'utf-8');

            // Kirim kontennya sebagai teks mentah
            response.setHeader('Content-Type', 'text/plain; charset=utf-8');
            response.status(200).send(scriptContent);
        } catch (error) {
            console.error("Gagal membaca sc.lua:", error);
            response.status(500).send('Error: Tidak dapat membaca file script.');
        }
    } else {
        // Jika BUKAN: Ini adalah browser
        try {
            // Baca file index.html dari root direktori proyek
            const filePath = path.join(process.cwd(), 'index.html');
            const htmlContent = await fs.readFile(filePath, 'utf-8');

            // Kirim kontennya sebagai halaman HTML
            response.setHeader('Content-Type', 'text/html; charset=utf-8');
            response.status(200).send(htmlContent);
        } catch (error) {
            console.error("Gagal membaca index.html:", error);
            response.status(500).send('Error: Tidak dapat membaca file halaman.');
        }
    }
}
