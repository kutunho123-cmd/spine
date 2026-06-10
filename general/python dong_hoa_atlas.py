import os
import re

def natural_keys(text):
    '''
    Sắp xếp chuỗi chứa số theo thứ tự tự nhiên (ví dụ: sx_2 đứng trước sx_10)
    '''
    return [int(c) if c.isdigit() else c for c in re.split(r'(\d+)', text)]

def process_atlas(input_path, output_path):
    with open(input_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    pages = []
    current_page = {"header": [], "regions": {}}
    current_region = None
    
    for line in lines:
        stripped = line.strip()
        if not stripped:
            continue
            
        is_indented = line.startswith(' ') or line.startswith('	')
        
        if not is_indented:
            # Kiểm tra nếu là thuộc tính header của trang (size, format, filter, repeat)
            if ':' in stripped and stripped.split(':')[0].strip().lower() in ['size', 'format', 'filter', 'repeat', 'pma']:
                current_page["header"].append(line)
            # Kiểm tra nếu là tên file ảnh (png, jpg, jpeg) -> Bắt đầu một trang mới
            elif stripped.lower().endswith(('.png', '.jpg', '.jpeg')):
                if current_page["header"] or current_page["regions"]:
                    pages.append(current_page)
                    current_page = {"header": [], "regions": {}}
                current_page["header"].append(line)
            else:
                # Đây là tên của một region (sprite)
                current_region = stripped
                if current_region not in current_page["regions"]:
                    current_page["regions"][current_region] = []
        else:
            # Đây là thuộc tính của region (xy, size, rotate...)
            if current_region is not None:
                current_page["regions"][current_region].append(line)
            else:
                current_page["header"].append(line)
                
    if current_page["header"] or current_page["regions"]:
        pages.append(current_page)
        
    # Ghi ra file mới
    with open(output_path, 'w', encoding='utf-8') as f:
        for page in pages:
            # Ghi header của page
            for h in page["header"]:
                f.write(h)
            
            # Sắp xếp các regions theo thứ tự tự nhiên (sx_1, sx_2... sx_10)
            sorted_regions = sorted(page["regions"].keys(), key=natural_keys)
            for r in sorted_regions:
                f.write(r + "
")
                for prop in page["regions"][r]:
                    # Đảm bảo thuộc tính được thụt lề chuẩn (2 space)
                    if not prop.startswith('  '):
                        f.write('  ' + prop.lstrip())
                    else:
                        f.write(prop)

def main():
    current_dir = os.getcwd()
    output_dir = os.path.join(current_dir, "synced_atlas")
    
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
        
    found_files = False
    # Xử lý tất cả các file .atlas hoặc .txt
    for filename in os.listdir(current_dir):
        if filename.endswith(".atlas") or filename.endswith(".txt"):
            input_path = os.path.join(current_dir, filename)
            output_path = os.path.join(output_dir, filename)
            print(f"Đang đồng hóa: {filename}")
            try:
                process_atlas(input_path, output_path)
                found_files = True
            except Exception as e:
                print(f"Lỗi khi xử lý {filename}: {e}")
                
    if found_files:
        print(f"\nHoàn thành! Các file đã được đồng hóa nằm trong thư mục: {output_dir}")
    else:
        print("Không tìm thấy file .atlas hoặc .txt nào trong thư mục hiện tại.")

if __name__ == "__main__":
    main()