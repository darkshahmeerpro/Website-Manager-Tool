import sys
import os
import re

# This finds the AppData/Roaming folder on any Windows PC
appdata_folder = os.path.join(os.environ['APPDATA'], "WebsiteManager")
if not os.path.exists(appdata_folder):
    os.makedirs(appdata_folder)

hosts_path = r"C:\Windows\System32\drivers\etc\hosts"
log_file = os.path.join(appdata_folder, "blocked_sites.txt")
redirect = "127.0.0.1"

def is_valid_site(site):
    pattern = re.compile(r"^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
    return pattern.match(site)

def get_blocked_list():
    if not os.path.exists(log_file): return []
    with open(log_file, "r") as f:
        return sorted(list(set([line.strip() for line in f.readlines() if line.strip()])))

def update_log(site_list):
    with open(log_file, "w") as f:
        for site in site_list:
            f.write(f"{site}\n")

def manage_site(site, choice):
    if not is_valid_site(site):
        print(f"\n[!] ERROR: '{site}' is not a valid website format.")
        return

    domains = [site, f"www.{site}"] if not site.startswith("www.") else [site, site.replace("www.", "")]
    current_blocked = get_blocked_list()
    
    try:
        with open(hosts_path, "r") as f:
            lines = f.readlines()

        if choice == "1": # BLOCK
            with open(hosts_path, "a") as f:
                for d in domains:
                    if not any(d in line for line in lines):
                        f.write(f"\n{redirect} {d}")
            if site not in current_blocked:
                current_blocked.append(site)
            print(f"\n>>> SUCCESS: {site} blocked.")

        elif choice == "2": # UNBLOCK
            new_lines = [line for line in lines if not any(d in line for d in domains)]
            with open(hosts_path, "w") as f:
                f.writelines(new_lines)
            if site in current_blocked:
                current_blocked.remove(site)
            print(f"\n>>> SUCCESS: {site} unblocked.")

        update_log(current_blocked)

    except PermissionError:
        print("\n[!] ERROR: Access Denied. Run as Admin.")

if __name__ == "__main__":
    if len(sys.argv) > 2:
        manage_site(sys.argv[1].lower(), sys.argv[2])
