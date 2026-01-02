#!/usr/bin/env python3
"""
Create App IDE - Python Application Creator
Runs on AetherOS
"""

import os
import json
import sys
from datetime import datetime

# App storage directory
APP_DIR = "/apps"
METADATA_FILE = "/apps/apps.json"

class CreateAppIDE:
    def __init__(self):
        self.current_app = None
        self. code_buffer = ""
        self.apps = self.load_apps()
    
    def load_apps(self):
        """Load existing apps from storage"""
        if os.path. exists(METADATA_FILE):
            try:
                with open(METADATA_FILE, 'r') as f:
                    return json.load(f)
            except:
                return {}
        return {}
    
    def save_apps(self):
        """Save apps metadata"""
        os.makedirs(APP_DIR, exist_ok=True)
        with open(METADATA_FILE, 'w') as f:
            json.dump(self.apps, f, indent=2)
    
    def create_new_app(self, name):
        """Start creating a new application"""
        self.current_app = {
            "name": name,
            "created":  datetime.now().isoformat(),
            "code": ""
        }
        self.code_buffer = ""
        self. show_editor()
    
    def show_editor(self):
        """Display the Python code editor"""
        os.system('clear')
        print("╔════════════════════════════════════════════════════════════╗")
        print("║        Create App - Python IDE for ARM64 OS                ║")
        print("╚════════════════════════════════════════════════════════════╝")
        print(f"\n📝 App Name: {self.current_app['name']}")
        print("─" * 60)
        print("\n[EDITOR MODE] - Type your Python code below")
        print("Commands:  : save, :run, :clear, :exit")
        print("─" * 60 + "\n")
        
        self.edit_code()
    
    def edit_code(self):
        """Edit code interactively"""
        line_num = 1
        
        while True:
            try:
                line = input(f"{line_num: 3d} | ")
                
                if line. startswith(":"):
                    self.handle_command(line)
                    if line == ":exit":
                        break
                else:
                    if self.code_buffer:
                        self.code_buffer += "\n"
                    self.code_buffer += line
                    line_num += 1
                    
            except KeyboardInterrupt:
                print("\n\n[! ] Interrupted.  Save your work?  (y/n): ", end="")
                if input().lower() == 'y':
                    self.save_app()
                break
            except EOFError: 
                break
    
    def handle_command(self, cmd):
        """Handle IDE commands"""
        if cmd == ":save":
            self.save_app()
        elif cmd == ":run":
            self.run_app()
        elif cmd == ": clear":
            self.code_buffer = ""
            self.show_editor()
        elif cmd == ":exit": 
            print("[*] Exiting editor...")
            return
    
    def save_app(self):
        """Save the current app"""
        self.current_app["code"] = self.code_buffer
        
        app_file = os.path.join(APP_DIR, f"{self.current_app['name']}.py")
        os.makedirs(APP_DIR, exist_ok=True)
        
        with open(app_file, 'w') as f:
            f.write(self.code_buffer)
        
        self.apps[self.current_app['name']] = {
            "path": app_file,
            "created": self.current_app['created'],
            "size": len(self.code_buffer)
        }
        
        self. save_apps()
        print(f"\n✅ App '{self. current_app['name']}' saved!")
        print(f"📁 Location: {app_file}")
    
    def run_app(self):
        """Run the current app"""
        print("\n▶️  Running app.. .\n")
        try:
            exec(self.code_buffer, {})
        except Exception as e: 
            print(f"❌ Error:  {e}")
    
    def list_apps(self):
        """List all created apps"""
        os.system('clear')
        print("╔════════════════════════════════════════════════════════════╗")
        print("║                   Installed Apps                           ║")
        print("╚════════════════════════════════════════════════════════════╝\n")
        
        if not self.apps:
            print("No apps installed yet.\n")
            return
        
        for app_name, info in self.apps.items():
            created = info. get('created', 'Unknown')
            size = info.get('size', 0)
            print(f"📱 {app_name}")
            print(f"   Size: {size} bytes | Created: {created}")
            print()
    
    def run_existing_app(self, app_name):
        """Run an existing app"""
        if app_name not in self.apps:
            print(f"❌ App '{app_name}' not found")
            return
        
        app_file = self.apps[app_name]['path']
        try:
            with open(app_file, 'r') as f:
                code = f.read()
            print(f"\n▶️  Running {app_name}.. .\n")
            exec(code, {})
        except Exception as e:
            print(f"❌ Error: {e}")
    
    def main_menu(self):
        """Main menu"""
        while True:
            os.system('clear')
            print("╔════════════════════════════════════════════════════════════╗")
            print("║          ARM64 OS - Create App Python IDE                 ║")
            print("╚════════════════════════════════════════════════════════════╝\n")
            print("1. Create New App")
            print("2. List Apps")
            print("3. Run App")
            print("4. Exit")
            print("\nChoice: ", end="")
            
            choice = input().strip()
            
            if choice == '1':
                app_name = input("App Name: ").strip()
                if app_name:
                    self.create_new_app(app_name)
                    self.list_apps()
            elif choice == '2':
                self.list_apps()
                input("Press Enter to continue...")
            elif choice == '3':
                self.list_apps()
                app_name = input("App to run: ").strip()
                if app_name:
                    self.run_existing_app(app_name)
                    input("\nPress Enter to continue...")
            elif choice == '4':
                print("Exiting Create App IDE...")
                break

def main():
    ide = CreateAppIDE()
    ide.main_menu()

if __name__ == "__main__":
    main()