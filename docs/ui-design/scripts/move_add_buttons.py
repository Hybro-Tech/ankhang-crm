#!/usr/bin/env python3
"""
Script to move Add buttons from header to content area across wireframes.
"""

import os
import re

WIREFRAME_DIR = "/Users/doanhnoi/work/hybro/lawcrm/docs/ui-design/wireframes"

# Configuration for each page
PAGES_CONFIG = [
    {
        "file": "products.html",
        "title": "Danh sách sản phẩm",
        "subtitle": "Quản lý sản phẩm và dịch vụ của bạn",
        "button_text": "Thêm sản phẩm",
        "button_link": "products_form.html"
    },
    {
        "file": "employees.html", 
        "title": "Danh sách nhân viên",
        "subtitle": "Quản lý thông tin nhân viên",
        "button_text": "Thêm nhân viên",
        "button_link": "employees_form.html"
    },
    {
        "file": "deals.html",
        "title": "Cơ hội bán hàng",
        "subtitle": "Theo dõi pipeline bán hàng của bạn",
        "button_text": "Thêm cơ hội",
        "button_link": "deals_form.html"
    },
    {
        "file": "deals_list.html",
        "title": "Danh sách cơ hội",
        "subtitle": "Xem tất cả cơ hội dạng bảng",
        "button_text": "Thêm cơ hội",
        "button_link": "deals_form.html"
    }
]

def fix_page(config):
    filepath = os.path.join(WIREFRAME_DIR, config["file"])
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Pattern to find the add button in header (with variations)
    # Looking for: <a href="xxx_form.html" class="bg-brand-blue...">...Thêm xxx</a>
    add_button_pattern = re.compile(
        r'\s*<a href="' + config["button_link"] + r'"[^>]*class="bg-brand-blue[^"]*"[^>]*>\s*'
        r'<i class="fa-solid fa-plus[^"]*"></i>\s*' + re.escape(config["button_text"]) + r'\s*</a>\s*',
        re.DOTALL
    )
    
    # Check if add button exists in header area (before <!-- Content -->)
    header_end = content.find('<!-- Content -->')
    if header_end == -1:
        print(f"  SKIP (no Content marker): {config['file']}")
        return False
    
    header_section = content[:header_end]
    
    match = add_button_pattern.search(header_section)
    if not match:
        print(f"  SKIP (button not in header or already moved): {config['file']}")
        return False
    
    # Remove button from header
    new_content = content[:match.start()] + content[match.end():]
    
    # Find where to add the page title section (after <!-- Content --> and <div class="flex-1 overflow-auto p-6">)
    content_start = new_content.find('<!-- Content -->')
    div_after_content = new_content.find('<div class="flex-1 overflow-auto p-6">', content_start)
    
    if div_after_content == -1:
        print(f"  ERROR (can't find content div): {config['file']}")
        return False
    
    # Find the closing > of that div
    div_end = new_content.find('>', div_after_content) + 1
    
    # Create the page title section
    page_title_section = f'''
        <!-- Page Title & Action -->
        <div class="flex items-center justify-between mb-6">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">{config["title"]}</h1>
            <p class="text-sm text-gray-500 mt-1">{config["subtitle"]}</p>
          </div>
          <a href="{config["button_link"]}"
            class="bg-brand-blue text-white px-4 py-2 rounded-lg shadow hover:bg-blue-900 transition flex items-center">
            <i class="fa-solid fa-plus mr-2"></i> {config["button_text"]}
          </a>
        </div>
'''
    
    # Insert after the content div opening
    new_content = new_content[:div_end] + page_title_section + new_content[div_end:]
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    print(f"  UPDATED: {config['file']}")
    return True


def main():
    print("Moving Add buttons from header to content area...")
    print("-" * 50)
    
    updated = 0
    for config in PAGES_CONFIG:
        if fix_page(config):
            updated += 1
    
    print("-" * 50)
    print(f"Done! Updated: {updated}")


if __name__ == "__main__":
    main()
