import sys
import uuid
import re

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

    # Find the Sources build phase to add to (safe approach: split and insert)
    sources_section_marker = "isa = PBXSourcesBuildPhase;"
    if sources_section_marker in content:
        parts = content.split("isa = PBXSourcesBuildPhase;", 1)
        files_list_marker = "files = ("
        if files_list_marker in parts[1]:
            subparts = parts[1].split(files_list_marker, 1)
            parts[1] = subparts[0] + files_list_marker + f"\n\t\t\t\t{build_file} /* {file_name} in Sources */," + subparts[1]
            content = parts[0] + "isa = PBXSourcesBuildPhase;" + parts[1]

    # Find PBXGroup to add to (just add to the main Atlas group safely)
    atlas_group_marker = "/* Atlas */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = ("
    if atlas_group_marker in content:
        parts = content.split(atlas_group_marker, 1)
        content = parts[0] + atlas_group_marker + f"\n\t\t\t\t{file_ref} /* {file_name} */," + parts[1]
    else:
        # Fallback: Just put it in the very first group's children
        group_marker = "isa = PBXGroup;\n\t\t\tchildren = ("
        if group_marker in content:
            parts = content.split(group_marker, 1)
            content = parts[0] + group_marker + f"\n\t\t\t\t{file_ref} /* {file_name} */," + parts[1]

    with open(pbxproj_path, 'w') as f:
        f.write(content)
        
    print(f"Added {file_name}")

if __name__ == "__main__":
    main()
