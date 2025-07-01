export async function onRequest(context) {
  // Ambil User-Agent dari header request
  const userAgent = context.request.headers.get('user-agent') || '';

  // Periksa apakah request datang dari Roblox
  if (userAgent.includes('Roblox')) {
    // INI ADALAH EXECUTOR ROBLOX
    
    // Ambil konten dari file script PRIBADI Anda (_sc.lua)
    // context.env.ASSETS.fetch adalah cara untuk membaca file proyek dari dalam fungsi.
    const privateScriptAsset = await context.env.ASSETS.fetch(new URL('/_sc.lua', context.request.url));

    // Kirim konten script sebagai respons dengan tipe konten teks biasa
    return new Response(privateScriptAsset.body, {
      headers: {
        'Content-Type': 'text/plain; charset=utf-8'
      },
    });

  } else {
    // INI ADALAH BROWSER ATAU KLIEN LAIN
    
    // Ambil konten dari halaman HTML PUBLIK Anda (index.html)
    const publicPageAsset = await context.env.ASSETS.fetch(new URL('/index.html', context.request.url));

    // Kirim halaman HTML sebagai respons
    return new Response(publicPageAsset.body, {
      headers: {
        'Content-Type': 'text/html; charset=utf-8'
      },
    });
  }
}
