# LighttingModel

---

## 学习计划

- 理解各个名词含义和概念
- Blender shader节点的实现
- 在unity中用srp进行逐个实现
- 在d3d12中实现
- 在webgl中实现

---


## 光照模型的实现和技术细节

---

### 测量模型
- 数据量过于庞大，不适合用于游戏

### 传统经验光照模型

- 环境光项 用常量表示(改进，用IBL可以替换该常量项)
- 漫反射项 (Diffuse)
    - lambert 反射定律，随机反射。
- 高光反射项 (Specular)
    - 描述光线从入射到表面出射后有多少光线在视角向量的投影值
    - phong 镜面反射 brdf 分布函数(计算目标：V * R)
    - blinn-phong 镜面反射 brdf 分布函数(计算目标：N * H)

--- 

### 基于物理分析的光照模型

- 环境光项
- 漫反射项


- 高光反射项(大多数基于blinn-phong)
    - Cook-Torrance 微表面模型: $f(l,v) = \cfrac{D ⋅ F ⋅ G }{4 ⋅ (n ⋅ h) ⋅ (n ⋅ v)}$
        - D 法线分布函数
        - G 几何遮挡函数
        - F 菲涅尔方程
        - Beckmann分布 $D= \cfrac{exp(-tan^2(\alpha)/m^2)}{\pi m^2 cos^4(\alpha)},\alpha = arccos(n⋅h) $
        - Beckmann分布 $D = \cfrac{1}{m^2cos^4\theta} e^{-(\frac{tan\theta}{m})^2}$
        - $G = min(1,\cfrac {2(h ⋅ n)(v⋅n)}{v⋅n},\cfrac {2(h ⋅ n)(l⋅n)}{v⋅n}) $
    - 微表面模型框架下 修改D 和G的函数体内容
    - blinn-phong的几何和法线分布如下
        - $D= \cfrac {e+2}{2π} (n⋅h)$
        - $G=(n⋅l)(n⋅v)$
    - GGX 模型
        - $G= $
        - $D= $

微表面

#### 技术方案