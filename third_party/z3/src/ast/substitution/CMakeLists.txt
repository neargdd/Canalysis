z3_add_component(substitution
  SOURCES
    demodulator_rewriter.cpp
    matcher.cpp
    substitution.cpp
    substitution_tree.cpp
    unifier.cpp
  COMPONENT_DEPENDENCIES
    ast
    rewriter
)
