
export const getMediaUrl = (url?: string | null): string => {
  if (!url) return '';
  
  
  if (url.startsWith('http') || url.startsWith('blob:') || url.startsWith('data:')) {
    return url;
  }
  
  
  if (url.startsWith('@media:')) {
    const filename = url.replace('@media:', '');
    return `http://localhost:8123/media/answers/${filename}`;
  }

  
  const path = url.startsWith('/') ? url : `/${url}`;
  
  
  
  return `http://localhost:8123${path}`;
};
