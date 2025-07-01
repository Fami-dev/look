export async function onRequest(context) {
  // Ambil User-Agent dari request header
  const userAgent = context.request.headers.get('user-agent') || '';

  // Periksa apakah request datang dari Roblox
  if (userAgent.includes('Roblox')) {
    // Jika YA, ini adalah game. Lanjutkan dan sajikan file asli (sc.lua)
    // context.next() akan menyajikan aset statis yang cocok dengan path.
    return context.next(); 
  } else {
    // Jika BUKAN (berarti browser), tampilkan halaman loader 'index.html'.
    const loaderPage = await context.env.ASSETS.fetch(new URL('/index.html', context.request.url));
    
    return new Response(loaderPage.body, {
      headers: { 'content-type': 'text/html;charset=UTF-8' },
    });
  }
}
