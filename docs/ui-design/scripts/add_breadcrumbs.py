#!/usr/bin/env python3
"""
Script to replace header title with breadcrumb navigation across all wireframes.
Header will only contain: breadcrumb (left) + bell + avatar (right)
"""

import os
import re

WIREFRAME_DIR = "/Users/doanhnoi/work/hybro/lawcrm/docs/ui-design/wireframes"

# Skip these files
SKIP_FILES = ["index.html", "forgot_password.html", "zalo_composer.html"]

# Breadcrumb configuration for each page
BREADCRUMBS = {
    "dashboard.html": [("Tổng quan", None)],
    "contacts_list.html": [("Kinh doanh", None), ("Khách hàng", None)],
    "contacts_form.html": [("Kinh doanh", None), ("Khách hàng", "contacts_list.html"), ("Thêm mới", None)],
    "contact_detail.html": [("Kinh doanh", None), ("Khách hàng", "contacts_list.html"), ("Chi tiết", None)],
    "deals.html": [("Kinh doanh", None), ("Cơ hội", None)],
    "deals_list.html": [("Kinh doanh", None), ("Cơ hội", "deals.html"), ("Danh sách", None)],
    "deals_form.html": [("Kinh doanh", None), ("Cơ hội", "deals.html"), ("Thêm mới", None)],
    "deal_detail.html": [("Kinh doanh", None), ("Cơ hội", "deals.html"), ("Chi tiết", None)],
    "products.html": [("Kinh doanh", None), ("Sản phẩm", None)],
    "products_form.html": [("Kinh doanh", None), ("Sản phẩm", "products.html"), ("Thêm mới", None)],
    "coupons.html": [("Kinh doanh", None), ("Khuyến mãi", None)],
    "coupons_form.html": [("Kinh doanh", None), ("Khuyến mãi", "coupons.html"), ("Thêm mới", None)],
    "teams.html": [("Tổ chức", None), ("Đội nhóm", None)],
    "teams_form.html": [("Tổ chức", None), ("Đội nhóm", "teams.html"), ("Thêm mới", None)],
    "roles.html": [("Tổ chức", None), ("Phân quyền", None)],
    "roles_form.html": [("Tổ chức", None), ("Phân quyền", "roles.html"), ("Thêm mới", None)],
    "employees.html": [("Tổ chức", None), ("Nhân viên", None)],
    "employees_form.html": [("Tổ chức", None), ("Nhân viên", "employees.html"), ("Thêm mới", None)],
    "reports.html": [("Hệ thống", None), ("Báo cáo", None)],
    "logs.html": [("Hệ thống", None), ("Nhật ký", None)],
    "notifications.html": [("Cài đặt", None), ("Thông báo", None)],
}


def generate_breadcrumb_html(crumbs):
    """Generate breadcrumb HTML from list of (name, link) tuples."""
    parts = []
    for i, (name, link) in enumerate(crumbs):
        if i > 0:
            parts.append('<i class="fa-solid fa-chevron-right text-gray-300 text-xs mx-2"></i>')
        
        if link:
            parts.append(f'<a href="{link}" class="text-gray-500 hover:text-brand-blue">{name}</a>')
        elif i == len(crumbs) - 1:
            # Last item - current page
            parts.append(f'<span class="text-gray-800 font-medium">{name}</span>')
        else:
            parts.append(f'<span class="text-gray-500">{name}</span>')
    
    return f'''<nav class="flex items-center text-sm">
          {''.join(parts)}
        </nav>'''


def update_header(filepath, filename):
    """Replace header title with breadcrumb."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Get breadcrumb config
    crumbs = BREADCRUMBS.get(filename, [(filename.replace('.html', '').title(), None)])
    breadcrumb_html = generate_breadcrumb_html(crumbs)
    
    # Find and replace the h2 title in header
    # Pattern: <h2 class="text-xl font-bold text-gray-800">...</h2>
    h2_pattern = re.compile(
        r'<h2 class="text-xl font-bold text-gray-800">[^<]*</h2>',
        re.DOTALL
    )
    
    if h2_pattern.search(content):
        new_content = h2_pattern.sub(breadcrumb_html, content)
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"  UPDATED: {filename}")
        return True
    else:
        print(f"  SKIP (no h2 found): {filename}")
        return False


def main():
    print("Replacing header titles with breadcrumbs...")
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
        if update_header(filepath, filename):
            updated += 1
        else:
            skipped += 1
    
    print("-" * 50)
    print(f"Done! Updated: {updated}, Skipped: {skipped}")


if __name__ == "__main__":
    main()
