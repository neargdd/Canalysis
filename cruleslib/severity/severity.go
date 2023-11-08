/*
NaiveSystems Analyze - A tool for static code analysis
Copyright (C) 2023  Naive Systems Ltd.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

/*
This package should not import any packages of other analyzers to
avoid recursive import.
*/
package severity

import (
	pb "naive.systems/analyzer/analyzer/proto"
)

const (
	Unknown int32 = iota
	Highest
	High
	Medium
	Low
	Lowest
)

// protobuf will ignore the field if value is 0
var severityToIntMap = map[string]int32{
	"highest": Highest,
	"high":    High,
	"medium":  Medium,
	"low":     Low,
	"lowest":  Lowest,
}

var severityMap = map[string]int32{
	"misra_c_2012/dir_1_1":    Medium,
	"misra_c_2012/dir_2_1":    High,
	"misra_c_2012/dir_3_1":    Medium,
	"misra_c_2012/dir_4_1":    High,
	"misra_c_2012/dir_4_2":    Low,
	"misra_c_2012/dir_4_3":    Medium,
	"misra_c_2012/dir_4_4":    Low,
	"misra_c_2012/dir_4_5":    Low,
	"misra_c_2012/dir_4_6":    Low,
	"misra_c_2012/dir_4_7":    High,
	"misra_c_2012/dir_4_8":    Low,
	"misra_c_2012/dir_4_9":    Low,
	"misra_c_2012/dir_4_10":   Medium,
	"misra_c_2012/dir_4_11":   High,
	"misra_c_2012/dir_4_12":   High,
	"misra_c_2012/dir_4_13":   Low,
	"misra_c_2012/dir_4_14":   High,
	"misra_c_2012/rule_1_1":   High,
	"misra_c_2012/rule_1_2":   Low,
	"misra_c_2012/rule_1_3":   High,
	"misra_c_2012/rule_1_4":   Medium,
	"misra_c_2012/rule_2_1":   High,
	"misra_c_2012/rule_2_2":   Medium,
	"misra_c_2012/rule_2_3":   Low,
	"misra_c_2012/rule_2_4":   Low,
	"misra_c_2012/rule_2_5":   Low,
	"misra_c_2012/rule_2_6":   Low,
	"misra_c_2012/rule_2_7":   Low,
	"misra_c_2012/rule_3_1":   Medium,
	"misra_c_2012/rule_3_2":   High,
	"misra_c_2012/rule_4_1":   High,
	"misra_c_2012/rule_4_2":   Low,
	"misra_c_2012/rule_5_1":   High,
	"misra_c_2012/rule_5_2":   High,
	"misra_c_2012/rule_5_3":   Medium,
	"misra_c_2012/rule_5_4":   High,
	"misra_c_2012/rule_5_5":   High,
	"misra_c_2012/rule_5_6":   Medium,
	"misra_c_2012/rule_5_7":   High,
	"misra_c_2012/rule_5_8":   High,
	"misra_c_2012/rule_5_9":   Low,
	"misra_c_2012/rule_6_1":   High,
	"misra_c_2012/rule_6_2":   High,
	"misra_c_2012/rule_7_1":   Medium,
	"misra_c_2012/rule_7_2":   Medium,
	"misra_c_2012/rule_7_3":   Medium,
	"misra_c_2012/rule_7_4":   High,
	"misra_c_2012/rule_8_1":   High,
	"misra_c_2012/rule_8_2":   Medium,
	"misra_c_2012/rule_8_3":   High,
	"misra_c_2012/rule_8_4":   High,
	"misra_c_2012/rule_8_5":   Medium,
	"misra_c_2012/rule_8_6":   High,
	"misra_c_2012/rule_8_7":   Low,
	"misra_c_2012/rule_8_8":   Medium,
	"misra_c_2012/rule_8_9":   Low,
	"misra_c_2012/rule_8_10":  High,
	"misra_c_2012/rule_8_11":  Low,
	"misra_c_2012/rule_8_12":  High,
	"misra_c_2012/rule_8_13":  Low,
	"misra_c_2012/rule_8_14":  Medium,
	"misra_c_2012/rule_9_1":   Highest,
	"misra_c_2012/rule_9_2":   High,
	"misra_c_2012/rule_9_3":   High,
	"misra_c_2012/rule_9_4":   Medium,
	"misra_c_2012/rule_9_5":   Medium,
	"misra_c_2012/rule_10_1":  High,
	"misra_c_2012/rule_10_2":  Medium,
	"misra_c_2012/rule_10_3":  High,
	"misra_c_2012/rule_10_4":  Medium,
	"misra_c_2012/rule_10_5":  Low,
	"misra_c_2012/rule_10_6":  Medium,
	"misra_c_2012/rule_10_7":  Medium,
	"misra_c_2012/rule_10_8":  Medium,
	"misra_c_2012/rule_11_1":  High,
	"misra_c_2012/rule_11_2":  High,
	"misra_c_2012/rule_11_3":  High,
	"misra_c_2012/rule_11_4":  Low,
	"misra_c_2012/rule_11_5":  Low,
	"misra_c_2012/rule_11_6":  High,
	"misra_c_2012/rule_11_7":  High,
	"misra_c_2012/rule_11_8":  High,
	"misra_c_2012/rule_11_9":  Medium,
	"misra_c_2012/rule_12_1":  Low,
	"misra_c_2012/rule_12_2":  High,
	"misra_c_2012/rule_12_3":  Low,
	"misra_c_2012/rule_12_4":  Low,
	"misra_c_2012/rule_12_5":  Highest,
	"misra_c_2012/rule_13_1":  High,
	"misra_c_2012/rule_13_2":  High,
	"misra_c_2012/rule_13_3":  Low,
	"misra_c_2012/rule_13_4":  Low,
	"misra_c_2012/rule_13_5":  High,
	"misra_c_2012/rule_13_6":  Highest,
	"misra_c_2012/rule_14_1":  High,
	"misra_c_2012/rule_14_2":  High,
	"misra_c_2012/rule_14_3":  High,
	"misra_c_2012/rule_14_4":  Medium,
	"misra_c_2012/rule_15_1":  Low,
	"misra_c_2012/rule_15_2":  High,
	"misra_c_2012/rule_15_3":  High,
	"misra_c_2012/rule_15_4":  Low,
	"misra_c_2012/rule_15_5":  Low,
	"misra_c_2012/rule_15_6":  Medium,
	"misra_c_2012/rule_15_7":  Medium,
	"misra_c_2012/rule_16_1":  High,
	"misra_c_2012/rule_16_2":  High,
	"misra_c_2012/rule_16_3":  Medium,
	"misra_c_2012/rule_16_4":  Medium,
	"misra_c_2012/rule_16_5":  Medium,
	"misra_c_2012/rule_16_6":  Medium,
	"misra_c_2012/rule_16_7":  Medium,
	"misra_c_2012/rule_17_1":  High,
	"misra_c_2012/rule_17_2":  High,
	"misra_c_2012/rule_17_3":  Highest,
	"misra_c_2012/rule_17_4":  Highest,
	"misra_c_2012/rule_17_5":  Low,
	"misra_c_2012/rule_17_6":  Highest,
	"misra_c_2012/rule_17_7":  Medium,
	"misra_c_2012/rule_17_8":  Low,
	"misra_c_2012/rule_18_1":  High,
	"misra_c_2012/rule_18_2":  High,
	"misra_c_2012/rule_18_3":  High,
	"misra_c_2012/rule_18_4":  Low,
	"misra_c_2012/rule_18_5":  Low,
	"misra_c_2012/rule_18_6":  High,
	"misra_c_2012/rule_18_7":  Medium,
	"misra_c_2012/rule_18_8":  Medium,
	"misra_c_2012/rule_19_1":  Highest,
	"misra_c_2012/rule_19_2":  Low,
	"misra_c_2012/rule_20_1":  Low,
	"misra_c_2012/rule_20_2":  High,
	"misra_c_2012/rule_20_3":  High,
	"misra_c_2012/rule_20_4":  High,
	"misra_c_2012/rule_20_5":  Low,
	"misra_c_2012/rule_20_6":  High,
	"misra_c_2012/rule_20_7":  High,
	"misra_c_2012/rule_20_8":  Medium,
	"misra_c_2012/rule_20_9":  High,
	"misra_c_2012/rule_20_10": Low,
	"misra_c_2012/rule_20_11": High,
	"misra_c_2012/rule_20_12": High,
	"misra_c_2012/rule_20_13": High,
	"misra_c_2012/rule_20_14": High,
	"misra_c_2012/rule_21_1":  High,
	"misra_c_2012/rule_21_2":  High,
	"misra_c_2012/rule_21_3":  High,
	"misra_c_2012/rule_21_4":  High,
	"misra_c_2012/rule_21_5":  High,
	"misra_c_2012/rule_21_6":  High,
	"misra_c_2012/rule_21_7":  High,
	"misra_c_2012/rule_21_8":  High,
	"misra_c_2012/rule_21_9":  High,
	"misra_c_2012/rule_21_10": High,
	"misra_c_2012/rule_21_11": High,
	"misra_c_2012/rule_21_12": Low,
	"misra_c_2012/rule_21_13": Highest,
	"misra_c_2012/rule_21_14": High,
	"misra_c_2012/rule_21_15": High,
	"misra_c_2012/rule_21_16": High,
	"misra_c_2012/rule_21_17": Highest,
	"misra_c_2012/rule_21_18": Highest,
	"misra_c_2012/rule_21_19": Highest,
	"misra_c_2012/rule_21_20": Highest,
	"misra_c_2012/rule_21_21": High,
	"misra_c_2012/rule_22_1":  High,
	"misra_c_2012/rule_22_2":  Highest,
	"misra_c_2012/rule_22_3":  High,
	"misra_c_2012/rule_22_4":  Highest,
	"misra_c_2012/rule_22_5":  Highest,
	"misra_c_2012/rule_22_6":  Highest,
	"misra_c_2012/rule_22_7":  High,
	"misra_c_2012/rule_22_8":  High,
	"misra_c_2012/rule_22_9":  High,
	"misra_c_2012/rule_22_10": Medium,
	"java/S1111":              Medium,
	"java/S1114":              High,
	"java/S1143":              High,
	"java/S1145":              Medium,
	"java/S1175":              High,
	"java/S1201":              Medium,
	"java/S1217":              Medium,
	"java/S1221":              Medium,
	"java/S1244":              Medium,
	"java/S1317":              Medium,
	"java/S1656":              Medium,
	"java/S1697":              Medium,
	"java/S1751":              Medium,
	"java/S1764":              Medium,
	"java/S1848":              Medium,
	"java/S1849":              Medium,
	"java/S1850":              Medium,
	"java/S1860":              Medium,
	"java/S1862":              Medium,
	"java/S1872":              Medium,
	"java/S1875":              Medium,
	"java/S1968":              Medium,
	"java/S1987":              Medium,
	"java/S2060":              Medium,
	"java/S2061":              Medium,
	"java/S2095":              Highest,
	"java/S2107":              Medium,
	"java/S2109":              Medium,
	"java/S2110":              Medium,
	"java/S2111":              Medium,
	"java/S2114":              Medium,
	"java/S2116":              Medium,
	"java/S2118":              Medium,
	"java/S2119":              High,
	"java/S2120":              Medium,
	"java/S2121":              Medium,
	"java/S2122":              High,
	"java/S2123":              Medium,
	"java/S2127":              Medium,
	"java/S2134":              Medium,
	"java/S2141":              Medium,
	"java/S2142":              Medium,
	"java/S2144":              Highest,
	"java/S2150":              Highest,
	"java/S2151":              High,
	"java/S2154":              Medium,
	"java/S2159":              Medium,
	"java/S2168":              Highest,
	"java/S2175":              Medium,
	"java/S2177":              Medium,
	"java/S2180":              Medium,
	"java/S2189":              Highest,
	"java/S2190":              Highest,
	"java/S2201":              Medium,
	"java/S2204":              Medium,
	"java/S2206":              Highest,
	"java/S2213":              Medium,
	"java/S2222":              High,
	"java/S2225":              Medium,
	"java/S2226":              Medium,
	"java/S2229":              Highest,
	"java/S2230":              Medium,
	"java/S2236":              Highest,
	"java/S2251":              Medium,
	"java/S2252":              Medium,
	"java/S2259":              Medium,
	"java/S2273":              Medium,
	"java/S2275":              Highest,
	"java/S2276":              Highest,
	"java/S2389":              Medium,
	"java/S2441":              Medium,
	"java/S2445":              Medium,
	"java/S2446":              Medium,
	"java/S2526":              Highest,
	"java/S2551":              High,
	"java/S2583":              Medium,
	"java/S2588":              High,
	"java/S2630":              High,
	"java/S2639":              Medium,
	"java/S2652":              High,
	"java/S2654":              High,
	"java/S2655":              High,
	"java/S2656":              High,
	"java/S2657":              High,
	"java/S2677":              Medium,
	"java/S2688":              Medium,
	"java/S2689":              Highest,
	"java/S2690":              Medium,
	"java/S2691":              Medium,
	"java/S2695":              Highest,
	"java/S2752":              Medium,
	"java/S2757":              Medium,
	"java/S2761":              Medium,
	"java/S2789":              Medium,
	"java/S2792":              Highest,
	"java/S2857":              Highest,
	"java/S2885":              Medium,
	"java/S2886":              Medium,
	"java/S2887":              Medium,
	"java/S2997":              Medium,
	"java/S3018":              Medium,
	"java/S3019":              Medium,
	"java/S3028":              Medium,
	"java/S3034":              Medium,
	"java/S3035":              High,
	"java/S3037":              Medium,
	"java/S3039":              Medium,
	"java/S3040":              Medium,
	"java/S3041":              Medium,
	"java/S3046":              Highest,
	"java/S3049":              Medium,
	"java/S3051":              Highest,
	"java/S3053":              Medium,
	"java/S3062":              Medium,
	"java/S3064":              Medium,
	"java/S3065":              Medium,
	"java/S3067":              Medium,
	"java/S3072":              Highest,
	"java/S3074":              High,
	"java/S3075":              Medium,
	"java/S3076":              Medium,
	"java/S3078":              Medium,
	"java/S3249":              Medium,
	"java/S3263":              Medium,
	"java/S3269":              Medium,
	"java/S3306":              Medium,
	"java/S3346":              Medium,
	"java/S3356":              Highest,
	"java/S3436":              Medium,
	"java/S3475":              Medium,
	"java/S3518":              High,
	"java/S3546":              Highest,
	"java/S3551":              Medium,
	"java/S3554":              Medium,
	"java/S3655":              Medium,
	"java/S3673":              Medium,
	"java/S3676":              Medium,
	"java/S3750":              Medium,
	"java/S3753":              Highest,
	"java/S3923":              Medium,
	"java/S3949":              Medium,
	"java/S3955":              Medium,
	"java/S3958":              Medium,
	"java/S3959":              Medium,
	"java/S3981":              Medium,
	"java/S3984":              Medium,
	"java/S3986":              Medium,
	"java/S4143":              Medium,
	"java/S4265":              Medium,
	"java/S4275":              High,
	"java/S4348":              Medium,
	"java/S4351":              Medium,
	"java/S4517":              Medium,
	"java/S4602":              Highest,
	"java/S4973":              Medium,
	"java/S5164":              Medium,
	"java/S5338":              Highest,
	"java/S5779":              High,
	"java/S5783":              High,
	"java/S5790":              High,
	"java/S5810":              Medium,
	"java/S5831":              Medium,
	"java/S5833":              Medium,
	"java/S5840":              High,
	"java/S5845":              High,
	"java/S5850":              Medium,
	"java/S5855":              Medium,
	"java/S5856":              High,
	"java/S5863":              Medium,
	"java/S5866":              Medium,
	"java/S5868":              Medium,
	"java/S5917":              Medium,
	"java/S5960":              Medium,
	"java/S5967":              Medium,
	"java/S5979":              Highest,
	"java/S5994":              High,
	"java/S5996":              High,
	"java/S5998":              Medium,
	"java/S6001":              High,
	"java/S6002":              High,
	"java/S6070":              Medium,
	"java/S6073":              Medium,
	"java/S6103":              Medium,
	"java/S6104":              High,
	"java/S6209":              High,
	"java/S6216":              Medium,
	"java/S6218":              Medium,
	"java/S6320":              High,
	"java/S6322":              High,
	"java/S6416":              High,
	"java/S6417":              Medium,
}

func AddSeverity(resultsList *pb.ResultsList, ruleName string, customSeverity string) *pb.ResultsList {
	resultsListWithSeverity := &pb.ResultsList{}
	for _, result := range resultsList.Results {

		if severity, exist := severityMap[ruleName]; exist {
			result.Severity = severity
		} else {
			// rules with no severity
			result.Severity = Unknown
		}
		if customSeverity != "" {
			_, exist := severityToIntMap[customSeverity]
			if exist {
				result.Severity = severityToIntMap[customSeverity]
			}
		}
		resultsListWithSeverity.Results = append(resultsListWithSeverity.Results, result)
	}
	return resultsListWithSeverity
}

func GetSeverityMap() map[string]int32 {
	return severityMap
}