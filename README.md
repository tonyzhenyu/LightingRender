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
反射模型
散射模型
IBL

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
- 自发光 (emission)

--- 

### 基于物理分析的光照模型

反射等式，渲染方程 = 反射方程，着色模型 , 

直接光照和间接光照

- 环境光项 常量或者使用IBL照明(Image Base Lighting)
- 漫反射项
    - lambert 模型
- 高光反射项(大多数基于blinn-phong)
    - 基于微表面模型框架下 修改D 和G的函数体内容
    - blinn-phong的几何和法线分布如下
        - $D= \cfrac {e+2}{2π} (n⋅h)$
        - $G= (n⋅l)(n⋅v)$
    - GGX 模型
        - $D = \cfrac{\alpha^2}{\pi((n ⋅ m)^2(\alpha^2-1)+1)^2} $
        - $G = $

--- 

### 反射模型 Reflectance Model BRDF

cook-Torrance 、 phong 和 blinn-phong 三种光照模型的本质区别都在于 使用了不同的高光反射项(specular term)

- lambertian BRDF
    - $f_{Lambertian}(L,V) = \cfrac{diffuse\_reflectance}{\pi}$
    - $f(n,l) = \cfrac{k_d}{\pi}(N⋅L) $

- Cook-Torrance框架下的 blinn-phong 
    - $D = \cfrac {e+2}{2π} (n⋅h)$
    - $G = (n⋅l)(n⋅v)$
    - $F_{Schlick}(F_0,l,h) = F_0 + (1-F_0)(1-(l,h))^5$ F0为反射系数

- Disney (Burley) 漫反射模型
    - $F_{D90} = 0.5 + 2roughness ⋅ cos^2\theta_d$
    - $f_{Disney}(L,V) = \cfrac{diffuse\_reflectance}{\pi}(1+(F_{D90}-1)(1-\cos\theta_l)^5)(1+(F_{D90}-1)(1-\cos\theta_v))$
    - $\alpha = roughness^2$

- Oren-Nayar漫反射模型
    - $roughness_{OrenNayar} = \frac{1}{\sqrt{2}}arctan(roughness_{Beckmann})$
    - $f_{OrenNayar} (L,V) = \cfrac{diffuse\_reflectance}{\pi}(N⋅ L)(A+B⋅max(0,cos(\phi_v-\phi_l)sin\alpha ⋅tan\beta))$
    - $A = 1.0 - 0.5\frac{\sigma^2}{\sigma^2+0.33}$
    - $B = 0.45 \frac{\sigma^2}{\sigma^2+0.09}$
    - $\alpha = max(\theta_l,\theta_v)$
    - $\beta = min(\theta_l,\theta_v)$
    - $\phi_l,\phi_v$ 是方位角（即在法线垂直平面上投影的夹角）

- Cook-Torrance 微表面模型
    - Cook-Torrance 模型将光分为两个方面考虑：漫反射光强和镜面反射光强
        - $I_{cook-Torrance} = I_{diff}+I_{spec} = I_{diff}+K_sI_lR_s$
    - $f(l,v) = \cfrac{D ⋅ F ⋅ G }{4 ⋅ (n ⋅ h) ⋅ (n ⋅ v)}$
    - D 法线分布函数 NDF 对法线微分得到的凹凸率
    - G 几何遮挡函数 
    - F 菲涅尔方程
    - D：微表面分布函数，描述了微表面中有多少比例的微表面法向为H，即可以将L方向的光- 线反射到V方向。
    - F：Fresnel项，描述了在给定角度下多少光线会被反射离开表面
    - G：几何衰减项（后续也会讨论阴影遮蔽的G2项），描述了微表面互相投影遮蔽的效果，有时也用于BRDF的标准化。
    - 法线分布函数Beckmann ：$D = \cfrac{1}{\pi} \cfrac{1}{m^2cos^4\theta} e^{-(\frac{tan\theta}{m})^2},\theta = arccos(n⋅h)$
    - 几何遮挡函数：$G = min(1,\cfrac {2(h ⋅ n)(v⋅n)}{v⋅n},\cfrac {2(h ⋅ n)(l⋅n)}{v⋅n}) $

- Cook-Torrance 微表面模型描述2
    - 法线分布函数 Trowbridge-Reitz GGX： $NDF_{GGXTR}(n,h,\alpha) = \cfrac{\alpha^a}{\pi((n⋅h)^2(\alpha^2-1)+1)^2}$， $\alpha$ 是roughness
    - 菲涅尔方程： $F_{Schlick}(h,v,F_0) = F_0 + (1-F_0)(1-(h⋅v))^5$
    - 菲涅尔UE4 Epic F： $F(v,h) = F_0 + (1-F_0)2^{(-5.55473(v⋅h)-6.98316)(v⋅h)}$
    - Schlick GGX: $G_{schlickGGX}(n,v,k) = \cfrac{n⋅v}{(n⋅v)(1-k)+k} $ $,k_{direct} = \cfrac{(\alpha +1)^2}{8},k_{IBL}=\cfrac{\alpha^2}{2}$

- He-Torrance-Sillion-Greenberg 模型
    - He等人提出了一个更加复杂且完全物理的BRDF模型，它考虑了光线的偏振(polarization)、衍射、干涉、表面电导率以及掠射角更小的粗糙度。如果不考虑偏振则其模型为

- ward 模型
    - BRDF: $f_r(x,\psi\to\theta) = \cfrac{\rho_d}{\pi}+\rho_s \cfrac{e^{\frac{-\tan^2\theta_h}{\alpha^2}}}{4\pi\alpha^2 \sqrt{(N⋅\psi)(N⋅\theta)}}$
    - $\rho_d$ 漫反射的反射率
    - $\rho_s$ 镜面反射的反射率
    - $\alpha$ 表面粗糙度


---

## 微表面反射模型

### 微表面分布函数

分布项D描述了微表面的法线分布，即微表面中有多少比例的微表面法向为H，即可以将L方向的光线反射到V方向。
表面曲率是高光形状的主要因素（凹凸率）。

Q:什么是各项异性，各项异性在微表面分布时具体表现在那处？
添加方位角和天顶角的二元函数可以使得微表面法线的分布x != y

$\alpha 描述微表面粗糙度$

- Beckmann NDF
    - $D_{Beckmann} = \cfrac{e^{\cfrac{-\tan^2\theta_h}{\alpha^2}}}{\pi\alpha^2\cos^4\theta_h}$
    - $\tan^2\theta = \cfrac{1-\cos^2\theta}{\cos^2\theta}$ 
    - 微表面斜率均方根 $\tan^2\theta_h$
    - 简化可得: $D_{Beckmann} = \cfrac{e^{\cfrac{\cos^2\theta_h-1}{\alpha^2\cos^2\theta_h}}}{\pi\alpha^2\cos^4\theta_h}$
    - $\alpha = smoothness^2$

- GGX NDF
    - $D_{GGX} = \cfrac{\alpha^2}{\pi\cos^4\theta_h(\alpha^2+\tan^2\theta_h)^2}$
    - 简化可得：$D_{GGX} = \cfrac{\alpha^2}{\pi((\alpha^2-1)\cos^2\theta_h+1)^2}$
    - 各项异性的NDF 分布
        - GGX各向异性分布公式为： D(wh) = παxαycos4θh[1+ tan2θh(cos2ϕh/αx2 + sin2 ϕh/αy2)]21

- Blinn Phong NDF
    - $shininess = \cfrac{2}{\alpha^2} -2,\alpha = \sqrt{\cfrac{2}{shininess+2}}$
    - $D = \cfrac {e+2}{2π} (n⋅h)$

- Phong NDF
    - $D_p(h) = \cfrac{\alpha_p + 2}{2\pi}(n⋅h)^{\alpha_p}$
    - $smoothness = \alpha_p $
    - $各项异性的分布函数:D_{p(aniso)}(h) = \cfrac{\sqrt{(\alpha_x+2)(\alpha_y+2)}}{2\pi}(\cos\theta_h)^{\alpha_x\cos^2\phi_h + \alpha_y\sin^2\phi_h}$

### 几何衰减项

微表面的几何项是通过对表面轮廓的建模得到的，有两种常用的轮廓描述：V型槽模型认为微表面是由特定宽度和高度的V型凹槽组成的。

几何衰减发生的原因是：很多个微表面都是朝向能够反射入射光角度的方向，但最终只有离光源最近的微表面反射了光线

- Smith模型
    - $G_1(H,S) = \cfrac{1}{1+\lambda(a)}; a = \cfrac{(H⋅S)}{\alpha\sqrt{1-(H⋅S)^2}}$
    - $S=\begin{cases}L&or\\ V& \end{cases}$
    - $\lambda_{GGX}(a) = \cfrac{-1+\sqrt{1+\frac{1}{a^2}}}{2}$
    - $\lambda_{Beckmann}(a) = \begin{cases}\cfrac{1-1.259a+0.396a^2}{3.535a+2.181a^2}&, \text where &a < 1.6 \\ 0 &, \text where &a \geqslant 1.6\end{cases} $
    - $G_2(H,S) = G_1(H,L)⋅G_1(H,V)$
    - $G_2(H,S) = \cfrac{1}{1+G_1(H,L)+G_1(H,V)}$ 引入高度


### Fresnel项

需要检查

Fresnel项 描述了有多少光会被反射离开表面，即需要参与给定BRDF的计算。
光从一层材质到另一层时需要计算Fresnel项。

- Schlick Fresnel
    - $F = F_0+(F_{90}-F_0)(1-(h⋅v))^5$

- 法线方向的反射率
    - 计算中省掉了n和k项，但这会导致无法控制材质表现更接近绝缘体还是导体
    - 这个区别在金属反射的色相上是最明显的（因为部分波长的光被吸收了），而绝缘体的反射光则是光源的颜色不变。
    - 基于此我们就可以通过引入金属度修正金属的Fresnel反射，来计算默认绝缘体反射和金属基础色之间的过度：
    - 这里的F0是带有颜色的,高光流是直接取specular贴图颜色,金属流是mix(f0, baseColor, metallic)取得
    - $F_0 = lerp(F_{0Dielectrics},base\_color,metalness)$

- Lagarde用球面高斯近似来优化Schlick’s的菲涅尔项，UE4 也是这样应用的：
    - $F = F_0 + (F_{90}-F_0) * 2^{(-5.55473*u-6.983146)*u}$

---


## BRDF 合并


## BRDF 能量守恒



---

## Image Base Lighting

基于图像的光照(Image based lighting, IBL)是一类光照技术的集合
IBL 相当于一个无限大的球面光源在照射场景。辐射度由 environment map 决定。

主要思路就是预计算，把复杂的积分都先算好。我们会分别预计算漫反射项和镜面项，最终在实时渲染中只需通过简单的纹理采样即可得到结果。


1.要对cubemap卷积
2.对irradiance map进行采样




---

## Principle BRDF

- 对模型中所有项做混合
- 统一描述整个模型的光照情况

## disney principle BSDF

return ((1 / PI) * mix(Fd, ss, subsurface) * Cdlin + Fsheen) * (1 - metallic) + Gs * Fs * Ds + .25 * clearcoat * Gr * Fr * Dr;

- $f_d = \frac{basecolor}{\pi}(1+(F_{D90}-1)(1-\cos\theta_l)^5)(1+(F_{D90}-1)(1-\cos\theta_v)^5)$
    - $F_{D90} = 0.5 + 2roughness \cos^2\theta_d$

- $f_s = \cfrac{G_{GGX}D_{GTR}F_{schlick}}{4(n⋅v)(n⋅l)}$

## 技术方案

---

### 扩展阅读
- 透射模型 Transparent BTDF
- 散射模型 BSDF
- 大气散射模型


// [Burley 2012, "Physically-Based Shading at Disney"]
float3 Diffuse_Burley_Disney( float3 DiffuseColor, float Roughness, float NoV, float NoL, float VoH ){
           float FD90 = 0.5 + 2 * VoH * VoH * Roughness;       
           float FdV = 1 + (FD90 - 1) * Pow5( 1 - NoV );       
           float FdL = 1 + (FD90 - 1) * Pow5( 1 - NoL );       
           return DiffuseColor * ( (1 / PI) * FdV * FdL );
           }