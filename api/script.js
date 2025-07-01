import fs from 'fs';
import path from 'path';

export default function handler(request, response) {
  const userAgent = request.headers['user-agent'];

  if (userAgent && userAgent.includes('Roblox')) {
    try {
      // BENAR: Langsung baca dari root proyek
      const filePath = path.join(process.cwd(), '_internal_script.lua');
      const scriptContent = fs.readFileSync(filePath, 'utf-8');
      
      response.setHeader('Content-Type', 'text/plain; charset=utf-8');
      response.status(200).send(scriptContent);
    } catch (error) {
      console.error("Error reading script file:", error);
      response.status(500).send('Error: Could not read the script file on the server.');
    }
  } else {
    try {
      // BENAR: Langsung baca dari root proyek
      const forbiddenPagePath = path.join(process.cwd(), 'forbidden.html');
      const forbiddenPageContent = fs.readFileSync(forbiddenPagePath, 'utf-8');

      response.setHeader('Content-Type', 'text/html; charset=utf-8');
      response.status(403).send(forbiddenPageContent);
    } catch (error) {
      console.error("Error reading forbidden page:", error);
      response.status(500).send('Error: Could not load the forbidden page on the server.');
    }
  }
}
