/**
 * Formats a media URL to ensure it has the correct host and leading slash.
 * Handles absolute URLs, relative paths, and prevents double prepending.
 */
export const getMediaUrl = (url?: string | null): string => {
  if (!url) return '';
  
  // If it's already a full URL or blob URL, return as is
  if (url.startsWith('http') || url.startsWith('blob:') || url.startsWith('data:')) {
    return url;
  }
  
  // Handle legacy @media: placeholders
  if (url.startsWith('@media:')) {
    const filename = url.replace('@media:', '');
    return `http://localhost/media/answers/${filename}`;
  }

  // Ensure it has a leading slash
  const path = url.startsWith('/') ? url : `/${url}`;
  
  // Point to port 80 where Nginx is serving
  return `http://localhost${path}`;
};
