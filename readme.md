
Usage
=
run [original_package] [result_package] [svn_orig_package_revision_uri] [svn_revision_range_uri] [svn_revision_range] [sln_file_path]

* [original_package] - path to original ZIP package e.g. c:\project_1.0.zip
* [result_package] - path to result ZIP package e.g. c:\project_1_1_repack.zip
* [svn_orig_package_revision_uri] - svn revision locator e.g. https://repo.com/svn/project/trunk@2 
* [svn_revision_range_uri]  - svn revision range uri e.g. https://repo.com/svn/project/branches/BRANCH_1_0 
* [svn_revision_range] - revision range e.g. 2:HEAD
* [sln_file_path] - path to solution descriptor (*.sln file) inside checked out project e.g. project.sln

Example:
-------

run base.zip fina.zip https://subversion.assembla.com/svn/autobuild_ps/trunk@2 https://subversion.assembla.com/svn/autobuild_ps/trunk 2:6 ExApp.sln

