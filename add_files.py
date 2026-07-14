import sys
import uuid
import re

# Simple python script to add files to a pbxproj
def generate_id():
    return uuid.uuid4().hex[:24].upper()

def main():
    if len(sys.argv) < 3:
        print("Usage: python add_files.py <pbxproj> <file_path>")
        return

    pbxproj_path = sys.argv[1]
    file_path = sys.argv[2]
    file_name = file_path.split('/')[-1]
    
    with open(pbxproj_path, 'r') as f:
        content = f.read()

    if file_name in content:
        print(f"{file_name} already exists in pbxproj.")
        return

    file_ref = generate_id()
    build_file = generate_id()

    # Add PBXBuildFile
    build_file_str = f"		{build_file} /* {file_name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref} /* {file_name} */; }};\n"
    content = content.replace("/* End PBXBuildFile section */", build_file_str + "/* End PBXBuildFile section */")

    # Add PBXFileReference
    file_ref_str = f"		{file_ref} /* {file_name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {file_name}; sourceTree = \"<group>\"; }};\n"
    content = content.replace("/* End PBXFileReference section */", file_ref_str + "/* End PBXFileReference section */")

    # Find the Sources build phase to add to
    sources_match = re.search(r'isa = PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = .*?;\n\t\t\tfiles = \(\n(.*?)', content, re.DOTALL)
    if sources_match:
        content = content.replace(sources_match.group(1), f"\t\t\t\t{build_file} /* {file_name} in Sources */,\n{sources_match.group(1)}")

    # Add to main group or just let it float (it will compile if it's in Sources)
    # Finding a group to put it in is hard without knowing the structure. 
    # Just putting it in the main project group is fine for compilation.
    main_group_match = re.search(r'isa = PBXGroup;\n\t\t\tchildren = \(\n(.*?)', content, re.DOTALL)
    if main_group_match:
        content = content.replace(main_group_match.group(1), f"\t\t\t\t{file_ref} /* {file_name} */,\n{main_group_match.group(1)}", 1)

    with open(pbxproj_path, 'w') as f:
        f.write(content)
        
    print(f"Added {file_name}")

if __name__ == "__main__":
    main()
