/*
 *  Copyright (C) 2025  JNNGL
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#ifndef _SELLMEIER_GLSL
#define _SELLMEIER_GLSL 1

struct sellmeier_coeffs {
    vec3 B, C;
};

float sellmeier(sellmeier_coeffs coeffs, int lambda) {
    float wl2 = float(lambda) / 1000.0;
    wl2 *= wl2;
    
    vec3 t = (coeffs.B * wl2) / (vec3(wl2) - coeffs.C);
    return sqrt(1.0 + t.x + t.y + t.z);
}

const sellmeier_coeffs AIR = sellmeier_coeffs(vec3(0.0, 0.0, 0.0), vec3(1.0, 1.0, 1.0));

const sellmeier_coeffs FK5HTi = sellmeier_coeffs(vec3(0.909362180, 0.279077054, 0.891813298), vec3(0.005201425, 0.0158938446, 95.91094480));
const sellmeier_coeffs N_FK5 = sellmeier_coeffs(vec3(0.844309338, 0.344147824, 0.910790213), vec3(0.004751120, 0.0149814849, 97.86002930));
const sellmeier_coeffs N_FK51A = sellmeier_coeffs(vec3(0.971247817, 0.216901417, 0.904651666), vec3(0.004723020, 0.0153575612, 168.68133000));
const sellmeier_coeffs N_FK58 = sellmeier_coeffs(vec3(0.738042712, 0.363371967, 0.989296264), vec3(0.003390656, 0.0117551189, 212.84214500));
const sellmeier_coeffs N_PK51 = sellmeier_coeffs(vec3(1.156107750, 0.153229344, 0.785618966), vec3(0.005855974, 0.0194072416, 140.53704600));
const sellmeier_coeffs N_PK52A = sellmeier_coeffs(vec3(1.029607000, 0.188050600, 0.736488165), vec3(0.005168002, 0.0166658798, 138.96412900));
const sellmeier_coeffs N_PSK3 = sellmeier_coeffs(vec3(0.887272110, 0.489592425, 1.048652960), vec3(0.004698241, 0.0161818463, 104.37497500));
const sellmeier_coeffs N_PSK53A = sellmeier_coeffs(vec3(1.381218360, 0.196745645, 0.886089205), vec3(0.007064163, 0.0233251345, 97.48473450));
const sellmeier_coeffs SCHOTT_N_BK7 = sellmeier_coeffs(vec3(1.039612120, 0.231792344, 1.010469450), vec3(0.006000699, 0.0200179144, 103.56065300));
const sellmeier_coeffs N_BK7HT = sellmeier_coeffs(vec3(1.039612120, 0.231792344, 1.010469450), vec3(0.006000699, 0.0200179144, 103.56065300));
const sellmeier_coeffs N_BK7HTi = sellmeier_coeffs(vec3(1.039612120, 0.231792344, 1.010469450), vec3(0.006000699, 0.0200179144, 103.56065300));
const sellmeier_coeffs N_BK10 = sellmeier_coeffs(vec3(0.888308131, 0.328964475, 0.984610769), vec3(0.005169008, 0.0161190045, 99.75753310));
const sellmeier_coeffs P_BK7 = sellmeier_coeffs(vec3(1.183185030, 0.087175643, 1.031337010), vec3(0.007221420, 0.0268216805, 101.70236200));
const sellmeier_coeffs K7 = sellmeier_coeffs(vec3(1.127355500, 0.124412303, 0.827100531), vec3(0.007203417, 0.0269835916, 100.38458800));
const sellmeier_coeffs K10 = sellmeier_coeffs(vec3(1.156870820, 0.064262544, 0.872376139), vec3(0.008094243, 0.0386051284, 104.74773000));
const sellmeier_coeffs N_K5 = sellmeier_coeffs(vec3(1.085118330, 0.199562005, 0.930511663), vec3(0.006610995, 0.0241108660, 111.98277700));
const sellmeier_coeffs N_ZK7 = sellmeier_coeffs(vec3(1.077150320, 0.168079109, 0.851889892), vec3(0.006766017, 0.0230642817, 89.04987780));
const sellmeier_coeffs N_ZK7A = sellmeier_coeffs(vec3(1.075098910, 0.168895044, 0.860503983), vec3(0.006766017, 0.0230642817, 89.04987780));
const sellmeier_coeffs N_BAK1 = sellmeier_coeffs(vec3(1.123656620, 0.309276848, 0.881511957), vec3(0.006447428, 0.0222284402, 107.29775100));
const sellmeier_coeffs N_BAK2 = sellmeier_coeffs(vec3(1.016621540, 0.319903051, 0.937232995), vec3(0.005923838, 0.0203828415, 113.11841700));
const sellmeier_coeffs N_BAK4 = sellmeier_coeffs(vec3(1.288346420, 0.132817724, 0.945395373), vec3(0.007799806, 0.0315631177, 105.96587500));
const sellmeier_coeffs N_BAK4HT = sellmeier_coeffs(vec3(1.288346420, 0.132817724, 0.945395373), vec3(0.007799806, 0.0315631177, 105.96587500));
const sellmeier_coeffs N_BAF4 = sellmeier_coeffs(vec3(1.420563280, 0.102721269, 1.143809760), vec3(0.009420154, 0.0531087291, 110.27885600));
const sellmeier_coeffs N_BAF10 = sellmeier_coeffs(vec3(1.585149500, 0.143559385, 1.085212690), vec3(0.009266813, 0.0424489805, 105.61357300));
const sellmeier_coeffs N_BAF51 = sellmeier_coeffs(vec3(1.515036230, 0.153621958, 1.154279090), vec3(0.009427347, 0.0430826500, 124.88986800));
const sellmeier_coeffs N_BAF52 = sellmeier_coeffs(vec3(1.439034330, 0.096704605, 1.098758180), vec3(0.009078001, 0.0508212080, 105.69185600));
const sellmeier_coeffs N_BALF4 = sellmeier_coeffs(vec3(1.310041280, 0.142038259, 0.964929351), vec3(0.007965965, 0.0330672072, 109.19732000));
const sellmeier_coeffs N_BALF5 = sellmeier_coeffs(vec3(1.283859650, 0.071930094, 1.050489270), vec3(0.008258160, 0.0441920027, 107.09732400));
const sellmeier_coeffs N_SK2 = sellmeier_coeffs(vec3(1.281890120, 0.257738258, 0.968186040), vec3(0.007271916, 0.0242823527, 110.37777300));
const sellmeier_coeffs N_SK2HT = sellmeier_coeffs(vec3(1.281890120, 0.257738258, 0.968186040), vec3(0.007271916, 0.0242823527, 110.37777300));
const sellmeier_coeffs N_SK4 = sellmeier_coeffs(vec3(1.329937410, 0.228542996, 0.988465211), vec3(0.007168741, 0.0246455892, 100.88636400));
const sellmeier_coeffs N_SK5 = sellmeier_coeffs(vec3(0.991463823, 0.495982121, 0.987393925), vec3(0.005227305, 0.0172733646, 98.35945790));
const sellmeier_coeffs N_SK5HTi = sellmeier_coeffs(vec3(0.991463823, 0.495982121, 0.987393925), vec3(0.005227305, 0.0172733646, 98.35945790));
const sellmeier_coeffs N_SK11 = sellmeier_coeffs(vec3(1.179636310, 0.229817295, 0.935789652), vec3(0.006802821, 0.0219737205, 101.51323200));
const sellmeier_coeffs N_SK14 = sellmeier_coeffs(vec3(0.936155374, 0.594052018, 1.043745830), vec3(0.004617165, 0.0168859270, 103.73626500));
const sellmeier_coeffs N_SK16 = sellmeier_coeffs(vec3(1.343177740, 0.241144399, 0.994317969), vec3(0.007046873, 0.0229005000, 92.75085260));
const sellmeier_coeffs P_SK57 = sellmeier_coeffs(vec3(1.310534140, 0.169376189, 1.109877140), vec3(0.007408772, 0.0254563489, 107.75108700));
const sellmeier_coeffs P_SK57Q1 = sellmeier_coeffs(vec3(1.305364830, 0.171434328, 1.101172190), vec3(0.007364088, 0.0255786047, 106.72606000));
const sellmeier_coeffs P_SK58A = sellmeier_coeffs(vec3(1.316784100, 0.171154756, 1.125014730), vec3(0.007207175, 0.0245659595, 102.73972800));
const sellmeier_coeffs P_SK60 = sellmeier_coeffs(vec3(1.407904420, 0.143381417, 1.165139470), vec3(0.007843824, 0.0287769365, 105.37339700));
const sellmeier_coeffs N_KF9 = sellmeier_coeffs(vec3(1.192867780, 0.089334657, 0.920819805), vec3(0.008391547, 0.0404010786, 112.57244600));
const sellmeier_coeffs N_SSK2 = sellmeier_coeffs(vec3(1.430602700, 0.153150554, 1.013909040), vec3(0.008239830, 0.0333736841, 106.87082200));
const sellmeier_coeffs N_SSK5 = sellmeier_coeffs(vec3(1.592226590, 0.103520774, 1.051740160), vec3(0.009202846, 0.0423530072, 106.92737400));
const sellmeier_coeffs N_SSK8 = sellmeier_coeffs(vec3(1.448578670, 0.117965926, 1.069375280), vec3(0.008693101, 0.0421566593, 111.30066600));
const sellmeier_coeffs N_LAK7 = sellmeier_coeffs(vec3(1.236798890, 0.445051837, 1.017458880), vec3(0.006101055, 0.0201388334, 90.63803800));
const sellmeier_coeffs N_LAK8 = sellmeier_coeffs(vec3(1.331831670, 0.546623206, 1.190840150), vec3(0.006200239, 0.0216465439, 82.58277360));
const sellmeier_coeffs N_LAK9 = sellmeier_coeffs(vec3(1.462319050, 0.344399589, 1.155083720), vec3(0.007242702, 0.0243353131, 85.46868680));
const sellmeier_coeffs N_LAK10 = sellmeier_coeffs(vec3(1.728780170, 0.169257825, 1.193869560), vec3(0.008860146, 0.0363416509, 82.90090690));
const sellmeier_coeffs N_LAK12 = sellmeier_coeffs(vec3(1.173657040, 0.588992398, 0.978014394), vec3(0.005770318, 0.0200401678, 95.48734820));
const sellmeier_coeffs N_LAK14 = sellmeier_coeffs(vec3(1.507812120, 0.318866829, 1.142872130), vec3(0.007460987, 0.0242024834, 80.95651650));
const sellmeier_coeffs N_LAK21 = sellmeier_coeffs(vec3(1.227181160, 0.420783743, 1.012848430), vec3(0.006020757, 0.0196862889, 88.43700990));
const sellmeier_coeffs N_LAK22 = sellmeier_coeffs(vec3(1.142297810, 0.535138441, 1.040883850), vec3(0.005857786, 0.0198546147, 100.83401700));
const sellmeier_coeffs N_LAK28 = sellmeier_coeffs(vec3(1.504419860, 0.474120561, 1.177843540), vec3(0.007196656, 0.0249143227, 83.14432100));
const sellmeier_coeffs N_LAK33B = sellmeier_coeffs(vec3(1.422886010, 0.593661336, 1.161352600), vec3(0.006702835, 0.0219416210, 80.74077010));
const sellmeier_coeffs N_LAK34 = sellmeier_coeffs(vec3(1.266614420, 0.665919318, 1.124961200), vec3(0.005892781, 0.0197509041, 78.88941740));
const sellmeier_coeffs P_LAK35 = sellmeier_coeffs(vec3(1.393242600, 0.418882766, 1.043807000), vec3(0.007159597, 0.0233637446, 88.32844260));
const sellmeier_coeffs LLF1 = sellmeier_coeffs(vec3(1.216401250, 0.133664540, 0.883399468), vec3(0.008578072, 0.0420143003, 107.59306000));
const sellmeier_coeffs LLF1HTi = sellmeier_coeffs(vec3(1.225104450, 0.125155671, 0.892236751), vec3(0.008704321, 0.0427325235, 108.04996800));
const sellmeier_coeffs LF5 = sellmeier_coeffs(vec3(1.280356280, 0.163505973, 0.893930112), vec3(0.009298544, 0.0449135769, 110.49368500));
const sellmeier_coeffs LF5HTi = sellmeier_coeffs(vec3(1.285529240, 0.158357622, 0.892175122), vec3(0.009398863, 0.0452566659, 110.54482900));
const sellmeier_coeffs N_F2 = sellmeier_coeffs(vec3(1.397570370, 0.159201403, 1.268654300), vec3(0.009959061, 0.0546931752, 119.24834600));
const sellmeier_coeffs F2HT = sellmeier_coeffs(vec3(1.345333590, 0.209073176, 0.937357162), vec3(0.009977439, 0.0470450767, 111.88676400));
const sellmeier_coeffs F2HTi = sellmeier_coeffs(vec3(1.345333590, 0.209073176, 0.937357162), vec3(0.009977439, 0.0470450767, 111.88676400));
const sellmeier_coeffs F5 = sellmeier_coeffs(vec3(1.310446300, 0.196034260, 0.966129770), vec3(0.009586330, 0.0457627627, 115.01188300));
const sellmeier_coeffs N_BASF2 = sellmeier_coeffs(vec3(1.536520810, 0.156971102, 1.301968150), vec3(0.010843573, 0.0562278762, 131.33970000));
const sellmeier_coeffs N_BASF64 = sellmeier_coeffs(vec3(1.655542680, 0.171319770, 1.336644480), vec3(0.010448564, 0.0499394756, 118.96147200));
const sellmeier_coeffs N_LAF2 = sellmeier_coeffs(vec3(1.809842270, 0.157295550, 1.093003700), vec3(0.010171162, 0.0442431765, 100.68774800));
const sellmeier_coeffs N_LAF7 = sellmeier_coeffs(vec3(1.740287640, 0.226710554, 1.325255480), vec3(0.010792558, 0.0538626639, 106.26866500));
const sellmeier_coeffs N_LAF21 = sellmeier_coeffs(vec3(1.871345290, 0.250783010, 1.220486390), vec3(0.009333223, 0.0345637762, 83.24048660));
const sellmeier_coeffs N_LAF33 = sellmeier_coeffs(vec3(1.796534170, 0.311577903, 1.159818630), vec3(0.009273135, 0.0358201181, 87.34487120));
const sellmeier_coeffs N_LAF34 = sellmeier_coeffs(vec3(1.758369580, 0.313537785, 1.189252310), vec3(0.008728100, 0.0293020832, 85.17806440));
const sellmeier_coeffs P_LAF37 = sellmeier_coeffs(vec3(1.760032440, 0.248286745, 1.159351220), vec3(0.009380064, 0.0360537464, 86.43246930));
const sellmeier_coeffs LASF35 = sellmeier_coeffs(vec3(2.455058610, 0.453006077, 2.385130800), vec3(0.013567040, 0.0545803020, 167.90471500));
const sellmeier_coeffs N_LASF9 = sellmeier_coeffs(vec3(2.000295470, 0.298926886, 1.806918430), vec3(0.012142602, 0.0538736236, 156.53082900));
const sellmeier_coeffs N_LASF9HT = sellmeier_coeffs(vec3(2.000295470, 0.298926886, 1.806918430), vec3(0.012142602, 0.0538736236, 156.53082900));
const sellmeier_coeffs N_LASF31A = sellmeier_coeffs(vec3(1.964850750, 0.475231259, 1.483601090), vec3(0.009820602, 0.0344713438, 110.73986300));
const sellmeier_coeffs N_LASF40 = sellmeier_coeffs(vec3(1.985503310, 0.274057042, 1.289456610), vec3(0.010958331, 0.0474551603, 96.90852860));
const sellmeier_coeffs N_LASF41 = sellmeier_coeffs(vec3(1.863483310, 0.413307255, 1.357848150), vec3(0.009103682, 0.0339247268, 93.35805950));
const sellmeier_coeffs N_LASF43 = sellmeier_coeffs(vec3(1.935028270, 0.236629350, 1.262913440), vec3(0.010400141, 0.0447505292, 87.43756900));
const sellmeier_coeffs N_LASF44 = sellmeier_coeffs(vec3(1.788971050, 0.386758670, 1.305062430), vec3(0.008725063, 0.0308085023, 92.77438240));
const sellmeier_coeffs N_LASF45 = sellmeier_coeffs(vec3(1.871401980, 0.267777879, 1.730300080), vec3(0.011217192, 0.0505134972, 147.10650500));
const sellmeier_coeffs N_LASF45HT = sellmeier_coeffs(vec3(1.871401980, 0.267777879, 1.730300080), vec3(0.011217192, 0.0505134972, 147.10650500));
const sellmeier_coeffs N_LASF46A = sellmeier_coeffs(vec3(2.167015660, 0.319812761, 1.660044860), vec3(0.012359552, 0.0560610282, 107.04771800));
const sellmeier_coeffs N_LASF46B = sellmeier_coeffs(vec3(2.179889220, 0.306495184, 1.568824370), vec3(0.012580538, 0.0567191367, 105.31653800));
const sellmeier_coeffs N_LASF55 = sellmeier_coeffs(vec3(2.308612280, 0.354736638, 1.922271250), vec3(0.013044700, 0.0557524221, 133.19686900));
const sellmeier_coeffs P_LASF47 = sellmeier_coeffs(vec3(1.855431010, 0.315854649, 1.285618390), vec3(0.010032820, 0.0387095168, 94.54215070));
const sellmeier_coeffs P_LASF50 = sellmeier_coeffs(vec3(1.849105530, 0.329828674, 1.304009010), vec3(0.009992348, 0.0387437988, 95.89676810));
const sellmeier_coeffs P_LASF51 = sellmeier_coeffs(vec3(1.845688060, 0.339001600, 1.324189210), vec3(0.009884956, 0.0378097402, 97.84154300));
const sellmeier_coeffs N_SF1 = sellmeier_coeffs(vec3(1.608651580, 0.237725916, 1.515306530), vec3(0.011965488, 0.0590589722, 135.52167600));
const sellmeier_coeffs N_SF2 = sellmeier_coeffs(vec3(1.473431270, 0.163681849, 1.369208990), vec3(0.010901910, 0.0585683687, 127.40493300));
const sellmeier_coeffs N_SF4 = sellmeier_coeffs(vec3(1.677802820, 0.282849893, 1.635392760), vec3(0.012679345, 0.0602038419, 145.76049600));
const sellmeier_coeffs N_SF5 = sellmeier_coeffs(vec3(1.524818890, 0.187085527, 1.427290150), vec3(0.011254756, 0.0588995392, 129.14167500));
const sellmeier_coeffs N_SF6 = sellmeier_coeffs(vec3(1.779317630, 0.338149866, 2.087344740), vec3(0.013371418, 0.0617533621, 174.01759000));
const sellmeier_coeffs N_SF6HT = sellmeier_coeffs(vec3(1.779317630, 0.338149866, 2.087344740), vec3(0.013371418, 0.0617533621, 174.01759000));
const sellmeier_coeffs N_SF6HTultra = sellmeier_coeffs(vec3(1.779317630, 0.338149866, 2.087344740), vec3(0.013371418, 0.0617533621, 174.01759000));
const sellmeier_coeffs N_SF8 = sellmeier_coeffs(vec3(1.550758120, 0.209816918, 1.462054910), vec3(0.011433834, 0.0582725652, 133.24165000));
const sellmeier_coeffs N_SF10 = sellmeier_coeffs(vec3(1.621539020, 0.256287842, 1.644475520), vec3(0.012224146, 0.0595736775, 147.46879300));
const sellmeier_coeffs N_SF11 = sellmeier_coeffs(vec3(1.737596950, 0.313747346, 1.898781010), vec3(0.013188707, 0.0623068142, 155.23629000));
const sellmeier_coeffs N_SF14 = sellmeier_coeffs(vec3(1.690223610, 0.288870052, 1.704518700), vec3(0.013051211, 0.0613691880, 149.51768900));
const sellmeier_coeffs N_SF15 = sellmeier_coeffs(vec3(1.570556340, 0.218987094, 1.508240170), vec3(0.011650701, 0.0597856897, 132.70933900));
const sellmeier_coeffs N_SF57 = sellmeier_coeffs(vec3(1.875438310, 0.373757490, 2.300017970), vec3(0.014174952, 0.0640509927, 177.38979500));
const sellmeier_coeffs N_SF57HT = sellmeier_coeffs(vec3(1.875438310, 0.373757490, 2.300017970), vec3(0.014174952, 0.0640509927, 177.38979500));
const sellmeier_coeffs N_SF57HTultra = sellmeier_coeffs(vec3(1.875438310, 0.373757490, 2.300017970), vec3(0.014174952, 0.0640509927, 177.38979500));
const sellmeier_coeffs N_SF66 = sellmeier_coeffs(vec3(2.024597600, 0.470187196, 2.599704330), vec3(0.014705323, 0.0692998276, 161.81760100));
const sellmeier_coeffs P_SF8 = sellmeier_coeffs(vec3(1.553704110, 0.206332561, 1.397088310), vec3(0.011658267, 0.0582087757, 130.74802800));
const sellmeier_coeffs P_SF68 = sellmeier_coeffs(vec3(2.333006700, 0.452961396, 1.251723390), vec3(0.016883842, 0.0716086325, 118.70747900));
const sellmeier_coeffs P_SF69 = sellmeier_coeffs(vec3(1.625946470, 0.235927609, 1.674346230), vec3(0.012169668, 0.0600710405, 145.65190800));
const sellmeier_coeffs SF1 = sellmeier_coeffs(vec3(1.559129230, 0.284246288, 0.968842926), vec3(0.012148100, 0.0534549042, 112.17480900));
const sellmeier_coeffs SF2 = sellmeier_coeffs(vec3(1.403018210, 0.231767504, 0.939056586), vec3(0.010579547, 0.0493226978, 112.40595500));
const sellmeier_coeffs SF3 = sellmeier_coeffs(vec3(1.572305420, 0.339661149, 1.035937120), vec3(0.012038218, 0.0531603583, 120.00538100));
const sellmeier_coeffs SF4 = sellmeier_coeffs(vec3(1.619578260, 0.339493189, 1.025669310), vec3(0.012550210, 0.0544559822, 117.65222200));
const sellmeier_coeffs SF5 = sellmeier_coeffs(vec3(1.461418850, 0.247713019, 0.949995832), vec3(0.011182613, 0.0508594669, 112.04188800));
const sellmeier_coeffs SF6 = sellmeier_coeffs(vec3(1.724484820, 0.390104889, 1.045728580), vec3(0.013487195, 0.0569318095, 118.55718500));
const sellmeier_coeffs SF6HT = sellmeier_coeffs(vec3(1.724484820, 0.390104889, 1.045728580), vec3(0.013487195, 0.0569318095, 118.55718500));
const sellmeier_coeffs SF10 = sellmeier_coeffs(vec3(1.616259770, 0.259229334, 1.077623170), vec3(0.012753456, 0.0581983954, 116.60768000));
const sellmeier_coeffs SF11 = sellmeier_coeffs(vec3(1.738484030, 0.311168974, 1.174908710), vec3(0.013606860, 0.0615960463, 121.92271100));
const sellmeier_coeffs SF56A = sellmeier_coeffs(vec3(1.705792590, 0.344223052, 1.096018280), vec3(0.013387470, 0.0579561608, 121.61602400));
const sellmeier_coeffs SF57 = sellmeier_coeffs(vec3(1.816513710, 0.428893641, 1.071862780), vec3(0.014370420, 0.0592801172, 121.41994200));
const sellmeier_coeffs SF57HTultra = sellmeier_coeffs(vec3(1.816513710, 0.428893641, 1.071862780), vec3(0.014370420, 0.0592801172, 121.41994200));
const sellmeier_coeffs N_KZFS11 = sellmeier_coeffs(vec3(1.332224500, 0.289241610, 1.151617340), vec3(0.008402985, 0.0344239720, 88.43105320));
const sellmeier_coeffs N_KZFS2 = sellmeier_coeffs(vec3(1.236975540, 0.153569376, 0.903976272), vec3(0.007471705, 0.0308053556, 70.17310840));
const sellmeier_coeffs N_KZFS4 = sellmeier_coeffs(vec3(1.350554240, 0.197575506, 1.099629920), vec3(0.008762821, 0.0371767201, 90.38669940));
const sellmeier_coeffs N_KZFS4HT = sellmeier_coeffs(vec3(1.350554240, 0.197575506, 1.099629920), vec3(0.008762821, 0.0371767201, 90.38669940));
const sellmeier_coeffs N_KZFS5 = sellmeier_coeffs(vec3(1.474607890, 0.193584488, 1.265899740), vec3(0.009861438, 0.0445477583, 106.43625800));
const sellmeier_coeffs N_KZFS8 = sellmeier_coeffs(vec3(1.626936510, 0.243698760, 1.620071410), vec3(0.010880863, 0.0494207753, 131.00916300));
const sellmeier_coeffs BK7G18 = sellmeier_coeffs(vec3(1.265385420, 0.014419107, 1.003230280), vec3(0.008131041, 0.0543303226, 102.82116600));
const sellmeier_coeffs F2G12 = sellmeier_coeffs(vec3(1.347022240, 0.210037763, 19.535076800), vec3(0.009808506, 0.0471788018, 2279.15470000));
const sellmeier_coeffs K5G20 = sellmeier_coeffs(vec3(1.140943960, 0.145001190, 37.470578600), vec3(0.006949455, 0.0310574444, 4536.25624000));
const sellmeier_coeffs LAK9G15 = sellmeier_coeffs(vec3(1.287736670, 0.518244853, 26.175610900), vec3(0.005575419, 0.0223679524, 1892.25330000));
const sellmeier_coeffs LF5G19 = sellmeier_coeffs(vec3(1.346113270, 0.142428018, 0.900477176), vec3(0.009717439, 0.0501911619, 111.95970300));
const sellmeier_coeffs SF6G05 = sellmeier_coeffs(vec3(1.621139420, 0.506586092, 10.403229800), vec3(0.011347899, 0.0535840223, 1118.83658000));
const sellmeier_coeffs LF7 = sellmeier_coeffs(vec3(1.26879731, 0.156697051, 0.887676301), vec3(0.00919553925, 0.0447256764, 106.8203610));

const sellmeier_coeffs MgF2 = sellmeier_coeffs(vec3(0.48755108, 0.39875031, 2.3120353), vec3(0.04338408 * 0.04338408, 0.09461442 * 0.09461442, 23.793604 * 23.793604));
const sellmeier_coeffs SiO2 = sellmeier_coeffs(vec3(0.6961663, 0.4079426, 0.8974794), vec3(0.0684043 * 0.0684043, 0.1162414 * 0.1162414, 9.896161 * 9.896161));
const sellmeier_coeffs Al2O3 = sellmeier_coeffs(vec3(1.4313493, 0.65054713, 5.3414021), vec3(0.0726631 * 0.0726631, 0.1193242 * 0.1193242, 18.028251 * 18.028251));
const sellmeier_coeffs ZrO2 = sellmeier_coeffs(vec3(1.347091, 2.117788, 9.452943), vec3(0.062543 * 0.062543, 0.166739 * 0.166739, 24.320570 * 24.320570));

#endif // _SELLMEIER_GLSL