# rust 学习笔记

1. 安装
	OpenBSD上有现成的软件包，直接pkg_add rust

	其它系统，如果没有软件包：
	curl -sf -L https://static.rust-lang.org/rustup.sh | sh

1.a 为vim安装rust插件:
    先安装一个vim插件管理插件pathogen
    mkdir -p ~/.vim/{autoload,bundle}
    curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

    下载rust插件：

    git clone --depth=1 https://github.com/rust-lang/rust.vim.git ~/.vim/bundle/rust.vim

    添加到自己的.vimrc文件：

        execute pathogen#infect()

2. Hello World!
	编辑一个hello.rs的文件，写入一下内容：

	fn main() {
		println!("Hello World");
	}

	然后运行命令： rustc hello.rs
	会编译出一个名为hello的可执行程序
	运行hello程序:
		./hello

3. Hello world解释

	fn用于定义一个函数
	main()函数是一个入口函数，必须有。和C语言一样
	println后面的'!'表示它是一个宏（macro），而非函数
	表达式以;结尾
	println行缩进四个空格，而非一个tab
	
4. 使用cargo来管理rust项目（类似make之于C语言？）
    cargo用于做下面三件事情：
    a. 编译代码
    b. 下载依赖软件/文件
    c. 编译依赖

    使用cargo来做hello world程序：
    cargo new hello_world --bin

    ## cargo 自动创建hello_world文件夹并自动生成一个hello world的main.rs文件

    cd hello_world
    cargo run

    cargo还自动生成了一个Cargo.lock文件，用于追踪依赖关系；还生成一个Cargo.toml配置文件，用于项目的配置。
    Cargo.toml文件的内容：

        [package]
        name = "hello_world"
        version = "0.1.0"
        authors = ["root"]

    cargo build用于编译
    cargo run用于编译并运行
5. 
