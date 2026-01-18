#!/usr/bin/env python3
"""
Script to add bell notification dropdown to all wireframe headers.
Excludes: index.html (login), forgot_password.html (no header), zalo_composer.html (modal)
"""

import os
import re

WIREFRAME_DIR = "/Users/doanhnoi/work/hybro/lawcrm/docs/ui-design/wireframes"

# Files to skip (no header or special pages)
SKIP_FILES = ["index.html", "forgot_password.html", "zalo_composer.html", "notifications.html"]

# Bell dropdown HTML to insert
BELL_DROPDOWN_HTML = '''          <!-- Bell with Dropdown -->
          <div class="relative">
            <button onclick="document.getElementById('bellDropdown').classList.toggle('hidden')" class="relative focus:outline-none">
              <i class="fa-solid fa-bell text-gray-500 text-xl hover:text-gray-700"></i>
              <span class="absolute -top-1 -right-1 bg-brand-red text-white text-[10px] w-4 h-4 rounded-full flex items-center justify-center">3</span>
            </button>
            <!-- Dropdown -->
            <div id="bellDropdown" class="hidden absolute right-0 mt-2 w-80 bg-white rounded-lg shadow-xl border border-gray-200 z-50">
              <div class="px-4 py-3 border-b border-gray-200 bg-gray-50 flex justify-between items-center rounded-t-lg">
                <span class="font-bold text-gray-700">Thông báo</span>
                <span class="text-xs text-brand-blue cursor-pointer hover:underline">Đánh dấu đã đọc</span>
              </div>
              <div class="max-h-64 overflow-y-auto">
                <div class="px-4 py-3 border-b border-gray-100 bg-blue-50/50 hover:bg-gray-50 cursor-pointer flex items-start">
                  <div class="flex-shrink-0 mt-1">
                    <i class="fa-solid fa-user-plus text-brand-blue"></i>
                  </div>
                  <div class="ml-3 flex-1">
                    <p class="text-sm font-medium text-gray-900">Khách hàng mới được gán</p>
                    <p class="text-xs text-gray-500">KH2026-099 đã được gán cho bạn.</p>
                    <p class="text-[10px] text-gray-400 mt-1">5 phút trước</p>
                  </div>
                  <div class="ml-auto mt-2">
                    <div class="w-2 h-2 bg-brand-red rounded-full"></div>
                  </div>
                </div>
                <div class="px-4 py-3 border-b border-gray-100 hover:bg-gray-50 cursor-pointer flex items-start opacity-70">
                  <div class="flex-shrink-0 mt-1">
                    <i class="fa-solid fa-check-circle text-green-500"></i>
                  </div>
                  <div class="ml-3 flex-1">
                    <p class="text-sm font-medium text-gray-900">Deal chốt thành công</p>
                    <p class="text-xs text-gray-500">HD-2026-001 - 15,000,000 ₫</p>
                    <p class="text-[10px] text-gray-400 mt-1">1 giờ trước</p>
                  </div>
                </div>
              </div>
              <div class="px-4 py-2 bg-gray-50 text-center border-t border-gray-200 rounded-b-lg">
                <a href="notifications.html" class="text-xs font-medium text-brand-blue hover:underline">Xem tất cả</a>
              </div>
            </div>
          </div>'''


def add_bell_to_file(filepath):
    """Add bell dropdown to a wireframe file if not already present."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Skip if already has bell dropdown
    if 'bellDropdown' in content:
        print(f"  SKIP (already has bell): {os.path.basename(filepath)}")
        return False
    
    # Find the header section and the avatar image
    # Pattern: look for avatar img in header, insert bell before it
    # Match: <img class="h-8 w-8 rounded-full" src="...?name=Admin...
    
    avatar_pattern = r'(<img class="h-8 w-8 rounded-full"[^>]*src="https://ui-avatars\.com/api/\?name=Admin[^"]*"[^>]*>)'
    
    match = re.search(avatar_pattern, content)
    if match:
        # Insert bell dropdown before avatar
        new_content = content[:match.start()] + BELL_DROPDOWN_HTML + '\n          ' + content[match.start():]
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"  UPDATED: {os.path.basename(filepath)}")
        return True
    else:
        print(f"  SKIP (no avatar found): {os.path.basename(filepath)}")
        return False


def main():
    print("Adding bell notification to wireframes...")
    print("-" * 50)
    
    updated = 0
    skipped = 0
    
    for filename in sorted(os.listdir(WIREFRAME_DIR)):
        if not filename.endswith('.html'):
            continue
        
        if filename in SKIP_FILES:
            print(f"  SKIP (excluded): {filename}")
            skipped += 1
            continue
        
        filepath = os.path.join(WIREFRAME_DIR, filename)
        if add_bell_to_file(filepath):
            updated += 1
        else:
            skipped += 1
    
    print("-" * 50)
    print(f"Done! Updated: {updated}, Skipped: {skipped}")


if __name__ == "__main__":
    main()
