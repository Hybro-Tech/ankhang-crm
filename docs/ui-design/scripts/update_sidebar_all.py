import os
import re

# Configuration
WIRE_DIR = "/Users/doanhnoi/work/hybro/lawcrm/docs/ui-design/wireframes"
EXCLUDE_FILES = ["index.html"]

# Navigation Structure
# Format: (Label, Icon, Link, CategoryHeader)
# CategoryHeader is None if item doesn't start a new category
NAV_ITEMS = [
    # Top
    ("Tổng quan", "fa-chart-line", "dashboard.html", None),

    # Kinh doanh
    ("Khách hàng", "fa-users", "contacts_list.html", "Kinh doanh"),
    ("Cơ hội bán hàng", "fa-hand-holding-dollar", "deals.html", None),
    ("Sản phẩm", "fa-box-open", "products.html", None),
    ("Khuyến mãi", "fa-ticket", "coupons.html", None),

    # Tổ chức
    ("Đội nhóm", "fa-user-group", "teams.html", "Tổ chức"),
    ("Phân quyền", "fa-user-shield", "roles.html", None),
    ("Nhân viên", "fa-id-card", "employees.html", None),

    # Hệ thống
    ("Báo cáo", "fa-chart-pie", "reports.html", "Hệ thống"),
    ("Nhật ký hoạt động", "fa-list-check", "logs.html", None),
]

# Settings is separate at bottom
SETTINGS_LINK = "notifications.html"

# Mapping: Filename -> list of files that should highlight this link
# e.g. contacts_form.html should highligh contacts_list.html link
ACTIVE_MAPPING = {
    "dashboard.html": ["dashboard.html"],
    "contacts_list.html": ["contacts_list.html", "contacts_form.html", "contact_detail.html"],
    "deals.html": ["deals.html", "deals_form.html"],
    "products.html": ["products.html", "products_form.html"],
    "coupons.html": ["coupons.html", "coupons_form.html"],
    "teams.html": ["teams.html", "teams_form.html"],
    "roles.html": ["roles.html", "roles_form.html"],
    "employees.html": ["employees.html", "employees_form.html"],
    "reports.html": ["reports.html"],
    "logs.html": ["logs.html"],
    "notifications.html": ["notifications.html"],
}

def generate_sidebar_html(current_filename):
    html = []
    
    # Logo Section
    html.append('    <aside class="w-64 bg-brand-blue text-white flex flex-col flex-shrink-0 transition-all duration-300 shadow-xl z-50">')
    html.append('      <div class="h-16 flex items-center px-6 border-b border-blue-800 bg-brand-blue shadow-sm">')
    html.append('        <i class="fa-solid fa-scale-balanced text-white text-2xl mr-3"></i>')
    html.append('        <a href="dashboard.html" class="font-bold text-xl tracking-wide text-white hover:text-gray-200">AnKhangCRM</a>')
    html.append('      </div>')
    
    # Nav Items
    html.append('      <nav class="flex-1 px-3 py-6 space-y-1 overflow-y-auto">')
    
    for label, icon, link, header in NAV_ITEMS:
        # Add Header if present
        if header:
            html.append(f'        <div class="pt-6 pb-2 px-4 text-xs font-bold text-blue-300 uppercase tracking-wider">{header}</div>')
            
        # Determine Active State
        # Find which key in ACTIVE_MAPPING contains current_filename
        active_key = None
        for key, files in ACTIVE_MAPPING.items():
            if current_filename in files:
                active_key = key
                break
        
        is_active = (link == active_key)
        
        if is_active:
            # BRAND ORANGE for active state to stand out on Blue, or maybe a lighter blue/white combo
            # User wants "dep" (beautiful).
            # Using White bg + Blue Text is common for "Active" on Dark Sidebar, or a Lighter Blue.
            # Let's try White background with Brand Blue text for high contrast.
            classes = "flex items-center px-4 py-3 bg-white text-brand-blue rounded-lg shadow-md font-bold transition-all transform scale-105"
            icon_classes = f"fa-solid {icon} w-6 text-brand-orange" # Orange icon for contrast
        else:
            classes = "flex items-center px-4 py-2.5 text-blue-100 hover:text-white hover:bg-blue-800 rounded-lg transition-colors group font-medium"
            icon_classes = f"fa-solid {icon} w-6 text-blue-300 group-hover:text-white transition-colors"
            
        html.append(f'        <a href="{link}" class="{classes}">')
        html.append(f'          <i class="{icon_classes}"></i>')
        html.append(f'          <span>{label}</span>')
        html.append('        </a>')

    html.append('      </nav>')
    
    # Settings at Bottom
    html.append('      <div class="p-4 border-t border-blue-800 bg-blue-900/50">')
    
    # Check Active Settings
    is_settings_active = (current_filename in ACTIVE_MAPPING.get(SETTINGS_LINK, []))
    if is_settings_active:
         classes = "flex items-center px-4 py-2.5 bg-white text-brand-blue rounded-lg shadow-sm font-bold"
         icon_classes = "fa-solid fa-gear w-6 text-brand-orange"
    else:
         classes = "flex items-center px-4 py-2.5 text-blue-100 hover:text-white hover:bg-blue-800 rounded-lg transition-colors"
         icon_classes = "fa-solid fa-gear w-6 text-blue-300"
         
    html.append(f'        <a href="{SETTINGS_LINK}" class="{classes}">')
    html.append(f'          <i class="{icon_classes}"></i>')
    html.append('          <span class="font-medium">Cài đặt</span>')
    html.append('        </a>')
    
    # User Profile Snippet (Optional - adding for "Beauty")
    html.append('        <div class="mt-4 flex items-center px-2 pt-4 border-t border-blue-800/50">')
    html.append('          <img class="h-8 w-8 rounded-full border-2 border-blue-300" src="https://ui-avatars.com/api/?name=Admin&background=random" alt="Admin Avatar">')
    html.append('          <div class="ml-3">')
    html.append('            <p class="text-sm font-medium text-white">Admin User</p>')
    html.append('            <p class="text-xs text-blue-300">View Profile</p>')
    html.append('          </div>')
    html.append('        </div>')
    
    html.append('      </div>')
    html.append('    </aside>')
    
    return "\n".join(html)

def process_files():
    files = [f for f in os.listdir(WIRE_DIR) if f.endswith(".html") and f not in EXCLUDE_FILES]
    
    for filename in files:
        filepath = os.path.join(WIRE_DIR, filename)
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
            
        # Regex to find the Sidebar <aside>...</aside>
        # Assumption: The sidebar is the first <aside> block.
        # We look for <aside ...> ... </aside>
        # Using DOTALL to match newlines
        
        sidebar_pattern = re.compile(r'<aside.*?>.*?</aside>', re.DOTALL)
        
        match = sidebar_pattern.search(content)
        if match:
            print(f"Updating sidebar in: {filename}")
            new_sidebar = generate_sidebar_html(filename)
            new_content = content[:match.start()] + new_sidebar + content[match.end():]
            
            with open(filepath, "w", encoding="utf-8") as f:
                f.write(new_content)
        else:
            print(f"WARNING: No sidebar found in {filename}")

if __name__ == "__main__":
    process_files()
