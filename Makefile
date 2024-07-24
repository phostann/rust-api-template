# Makefile

# 定义变量
CARGO_TARGET = x86_64-unknown-linux-gnu
LINKER = x86_64-unknown-linux-gnu-gcc
DOCKER_IMAGE = atom-server
VERSION = latest
IMAGE_TAG = $(DOCKER_IMAGE):$(VERSION)
IMAGE_TAR = $(DOCKER_IMAGE)_$(VERSION).tar

# 默认目标
.PHONY: all
all: build

# 构建 Rust 程序
.PHONY: build
build:
	env CARGO_TARGET_$(CARGO_TARGET)_LINKER=$(LINKER) cargo build --target=$(CARGO_TARGET) --release

# 生成 entity 文件
.PHONY: entity
entity:
	sea-orm-cli generate entity -u sqlite://atom.db --date-time-crate chrono -o entity/src --with-serde both -l

# 清理构建文件
.PHONY: clean
clean:
	cargo clean

# 构建 Docker 镜像
.PHONY: docker
docker:
	docker buildx build --platform=linux/amd64 -t $(IMAGE_TAG) .

# 清理所有 Docker 镜像
.PHONY: clean-docker
clean-docker:
	docker rmi -f $(shell docker images -f "dangling=true" -q)

# 将 Docker 镜像保存为 tar 文件
.PHONY: save-docker
save-docker:
	docker save -o $(IMAGE_TAR) $(IMAGE_TAG)

# 显示帮助信息
.PHONY: help
help:
	@echo "Usage:"
	@echo "  make build        构建 Rust 程序"
	@echo "  make entity       生成 entity 文件"
	@echo "  make clean        清理构建文件"
	@echo "  make docker       构建 Docker 镜像"
	@echo "  make clean-docker 清理所有悬空 Docker 镜像"
	@echo "  make save-docker  将 Docker 镜像保存为 tar 文件"
	@echo "  make help         显示帮助信息"