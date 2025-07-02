import fs from 'fs';
import path from 'path';

export default function handler(request, response) {
  const userAgent = request.headers['user-agent'];
  const { name } = request.query;

  if (!name || name.includes('..')) {
    return response.status(400).send('// Invalid request');
  }

  const filePath = path.join(process.cwd(), '_internal', 'scripts', `${name}.lua`);

  if (!fs.existsSync(filePath)) {
    if (userAgent && userAgent.includes('Roblox')) {
      return response.status(404).send(`// 404: Script '${name}.lua' not found.`);
    } else {
      const forbiddenPagePath = path.join(process.cwd(), 'forbidden.html');
      const forbiddenPageContent = fs.readFileSync(forbiddenPagePath, 'utf-8');
      return response.status(404).setHeader('Content-Type', 'text/html; charset=utf-8').send(forbiddenPageContent);
    }
  }
  
  if (userAgent && userAgent.includes('Roblox')) {
    try {
      const scriptContent = fs.readFileSync(filePath, 'utf-8');
      response.setHeader('Content-Type', 'text/plain; charset=utf-8');
      response.status(200).send(scriptContent);
    } catch (error) {
      response.status(500).send('// 500: Server error while reading script.');
    }
  } else {
    try {
      const forbiddenPagePath = path.join(process.cwd(), 'forbidden.html');
      const forbiddenPageContent = fs.readFileSync(forbiddenPagePath, 'utf-8');
      response.setHeader('Content-Type', 'text/html; charset=utf-8');
      response.status(403).send(forbiddenPageContent);
    } catch (error) {
      response.status(500).send('<h1>Error 500</h1><p>Could not load page.</p>');
    }
  }
}
