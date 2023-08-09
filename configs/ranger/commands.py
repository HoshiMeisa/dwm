import os
from ranger.core.loader import CommandLoader
from ranger.api.commands import Command


class empty(Command):
    """
    :empty
    Empties the trash directory ~/.Trash
    """

    def execute(self):
        self.fm.run("rm -rf /home/myname/.Trash/{*,.[^.]*}")


class extracthere(Command):
    def execute(self):
        """ Extract copied files to current directory """
        copied_files = tuple(self.fm.copy_buffer)

        if not copied_files:
            return

        def refresh(_):
            cwd = self.fm.get_directory(original_path)
            cwd.load_content()

        one_file = copied_files[0]
        cwd = self.fm.thisdir
        original_path = cwd.path
        au_flags = ['-X', cwd.path]
        au_flags += self.line.split()[1:]
        au_flags += ['-e']

        self.fm.copy_buffer.clear()
        self.fm.cut_buffer = False
        if len(copied_files) == 1:
            descr = "extracting: " + os.path.basename(one_file.path)
        else:
            descr = "extracting files from: " + os.path.basename(one_file.dirname)
        obj = CommandLoader(args=['aunpack'] + au_flags \
                                 + [f.path for f in copied_files], descr=descr)

        obj.signal_bind('after', refresh)
        self.fm.loader.add(obj)


class extract(Command):
    """:extract <paths>

    Extract archives using 7z
    """

    def execute(self):
        import os
        fail = []
        for i in self.fm.thistab.get_selection():
            ExtractProg = '7z x'
            if i.path.endswith('.zip'):
                # zip encoding issue
                ExtractProg = 'unzip -O gbk'
            elif i.path.endswith('.tar.gz'):
                ExtractProg = 'tar xvf'
            elif i.path.endswith('.tar.xz'):
                ExtractProg = 'tar xJvf'
            elif i.path.endswith('.tar.bz2'):
                ExtractProg = 'tar xjvf'
            if os.system('{0} "{1}"'.format(ExtractProg, i.path)):
                fail.append(i.path)
        if len(fail) > 0:
            self.fm.notify("Fail to extract: {0}".format(' '.join(fail)), duration=10, bad=True)
        self.fm.redraw_window()


class compress(Command):
    def execute(self):
        """ Compress marked files to current directory """
        cwd = self.fm.thisdir
        marked_files = cwd.get_selection()

        if not marked_files:
            return

        def refresh(_):
            cwd = self.fm.get_directory(original_path)
            cwd.load_content()

        original_path = cwd.path
        parts = self.line.split()
        au_flags = parts[1:]

        descr = "compressing files in: " + os.path.basename(parts[1])
        obj = CommandLoader(args=['apack'] + au_flags + \
                [os.path.relpath(f.path, cwd.path) for f in marked_files], descr=descr)

        obj.signal_bind('after', refresh)
        self.fm.loader.add(obj)

    def tab(self):
        """ Complete with current folder name """

        extension = ['.zip', '.tar.gz', '.rar', '.7z']
        return ['compress ' + os.path.basename(self.fm.thisdir.path) + ext for ext in extension]