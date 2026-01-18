#!/usr/bin/env python3
"""
Script to standardize header across all wireframes to match dashboard style.
Replaces the old bell+avatar pattern with dashboard-style bell and avatar with name.
"""

import os
import re

WIREFRAME_DIR = "/Users/doanhnoi/work/hybro/lawcrm/docs/ui-design/wireframes"

# Files to skip (already have correct style, or special pages)
SKIP_FILES = ["index.html", "forgot_password.html", "zalo_composer.html", "dashboard.html", "notifications.html"]

# The standardized header right section (bell + avatar with name)
HEADER_RIGHT_SECTION = '''          <!-- Bell with Dropdown -->
          <div class="relative">
            <button onclick="document.getElementById('bellDropdown').classList.toggle('hidden')" class="relative p-1 rounded-full text-gray-400 hover:text-gray-500 focus:outline-none">
              <span class="absolute top-0 right-0 block h-2 w-2 rounded-full bg-brand-red ring-2 ring-white"></span>
              <i class="fa-regular fa-bell text-xl"></i>
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
          </div>
          <div class="flex items-center">
            <img class="h-8 w-8 rounded-full object-cover border border-gray-200"
              src="https://ui-avatars.com/api/?name=Admin+User&background=0B387A&color=fff" alt="User Avatar">
            <span class="ml-3 text-sm font-medium text-gray-700 hidden sm:block">Admin User</span>
            <i class="fa-solid fa-chevron-down ml-2 text-xs text-gray-400"></i>
          </div>'''


def update_header(filepath):
    """Update header to match dashboard style."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Pattern 1: Old style - Bell dropdown + simple avatar img
    old_pattern1 = re.compile(
        r'<!-- Bell with Dropdown -->.*?</div>\s*</div>\s*<img class="h-8 w-8 rounded-full"[^>]*>\s*</div>\s*</header>',
        re.DOTALL
    )
    
    # Pattern 2: Bell dropdown followed by any closing structure before </header>
    old_pattern2 = re.compile(
        r'(<!-- Bell with Dropdown -->.*?</div>\s*</div>\s*</div>)\s*<img class="h-8 w-8 rounded-full"[^>]*src="https://ui-avatars\.com/api/\?name=Admin[^"]*"[^>]*>\s*(</div>\s*</header>)',
        re.DOTALL
    )
    
    new_content = content
    updated = False
    
    # Try to find and replace the old avatar-only pattern
    # Search for: Bell dropdown ending + simple avatar img (no name, no chevron)
    simple_avatar_pattern = re.compile(
        r'(</div>\s*</div>)\s*(<img class="h-8 w-8 rounded-full"[^>]*src="https://ui-avatars\.com/api/\?name=Admin[^"]*"[^>]*>)\s*(</div>\s*</header>)',
        re.DOTALL
    )
    
    match = simple_avatar_pattern.search(content)
    if match:
        # Check if this is already the dashboard style (has "Admin User" text)
        if 'Admin User</span>' not in content[match.start():match.end()+200]:
            # Replace simple avatar with styled avatar section
            replacement = match.group(1) + '''
          <div class="flex items-center">
            <img class="h-8 w-8 rounded-full object-cover border border-gray-200"
              src="https://ui-avatars.com/api/?name=Admin+User&background=0B387A&color=fff" alt="User Avatar">
            <span class="ml-3 text-sm font-medium text-gray-700 hidden sm:block">Admin User</span>
            <i class="fa-solid fa-chevron-down ml-2 text-xs text-gray-400"></i>
          </div>
''' + match.group(3).replace(match.group(2), '')
            new_content = content[:match.start()] + replacement + content[match.end():]
            updated = True
    
    if updated:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"  UPDATED: {os.path.basename(filepath)}")
        return True
    else:
        # Check if already has the correct style
        if 'Admin User</span>' in content and 'fa-chevron-down' in content:
            print(f"  SKIP (already styled): {os.path.basename(filepath)}")
        else:
            print(f"  MANUAL CHECK NEEDED: {os.path.basename(filepath)}")
        return False


def main():
    print("Standardizing headers to match dashboard style...")
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
        if update_header(filepath):
            updated += 1
        else:
            skipped += 1
    
    print("-" * 50)
    print(f"Done! Updated: {updated}, Skipped: {skipped}")


if __name__ == "__main__":
    main()
