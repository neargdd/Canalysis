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

#include "autosar/rule_A7_2_4/libtooling/checker.h"

#include <glog/logging.h>

#include "absl/strings/str_format.h"
#include "misra/libtooling_utils/libtooling_utils.h"

using namespace misra::proto_util;
using namespace clang::ast_matchers;

using analyzer::proto::ResultsList;
using std::string;

namespace {

void ReportError(const std::string& path, int line_number,
                 ResultsList* results_list) {
  std::string error_message =
      "In an enumeration, either (1) none, (2) the first or (3) all enumerators shall be initialized.";
  misra::proto_util::AddResultToResultsList(results_list, path, line_number,
                                            error_message);
  LOG(INFO) << absl::StrFormat("%s, path: %s, line: %d", error_message, path,
                               line_number);
}

}  // namespace

namespace autosar {
namespace rule_A7_2_4 {
namespace libtooling {

class Callback : public ast_matchers::MatchFinder::MatchCallback {
 public:
  void Init(analyzer::proto::ResultsList* results_list,
            ast_matchers::MatchFinder* finder) {
    results_list_ = results_list;
    finder->addMatcher(
        enumDecl(unless(isExpansionInSystemHeader())).bind("enum"), this);
  }

  void run(const ast_matchers::MatchFinder::MatchResult& result) {
    const EnumDecl* enum_decl = result.Nodes.getNodeAs<EnumDecl>("enum");
    int enum_count = 0;
    int init_count = 0;
    int first_inited = false;

    for (const auto* it : enum_decl->enumerators()) {
      enum_count++;
      if (it->getInitExpr()) {
        init_count++;
        if (enum_count == 1) first_inited = true;
      }
    }

    if (!(init_count == 0 || (first_inited && init_count == 1) ||
          init_count == enum_count)) {
      std::string path =
          misra::libtooling_utils::GetFilename(enum_decl, result.SourceManager);
      int line_number =
          misra::libtooling_utils::GetLine(enum_decl, result.SourceManager);
      ReportError(path, line_number, results_list_);
    }
  }

 private:
  analyzer::proto::ResultsList* results_list_;
};

void Checker::Init(analyzer::proto::ResultsList* result_list) {
  results_list_ = result_list;
  callback_ = new Callback;
  callback_->Init(results_list_, &finder_);
}

}  // namespace libtooling
}  // namespace rule_A7_2_4
}  // namespace autosar