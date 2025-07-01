export async function onRequest(context) {
  // Ambil User-Agent dari request
  const userAgent = context.request.headers.get('user-agent') || '';

  // Jika User-Agent berisi "Roblox", ini adalah game.
  if (userAgent.includes('Roblox')) {
    // Lanjutkan dan sajikan file asli (sc.lua)
    return context.next(); 
  } else {
    // Jika bukan Roblox (berarti browser), tampilkan halaman password.
    const passwordPage = await context.env.ASSETS.fetch(new URL('/password.html', context.request.url));
    return new Response(passwordPage.body, {
      headers: { 'content-type': 'text/html;charset=UTF-8' },
    });
  }
}
