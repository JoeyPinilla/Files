#include <exception>
#include <iostream>
#include <sstream>
#include <boost/algorithm/string.hpp>
#include <boost/property_tree/xml_parser.hpp>
#include "pqrs/string.hpp"
#include "pqrs/xmlcompiler.hpp"

namespace pqrs {
  xmlcompiler::xmlcompiler(const std::string& system_xml_directory, const std::string& private_xml_directory) :
    system_xml_directory_(system_xml_directory),
    private_xml_directory_(private_xml_directory)
  {}

  void
  xmlcompiler::reload(void)
  {
    reload_replacementdef_();
    reload_symbolmap_();
    reload_appdef_();
    reload_devicedef_();
    reload_autogen_();
  }

  const std::string&
  xmlcompiler::get_error_message(void) const
  {
    return error_message_;
  }

  void
  xmlcompiler::read_xmls_(std::vector<ptree_ptr>& pt_ptrs, const std::vector<xml_file_path_ptr>& xml_file_path_ptrs)
  {
    pt_ptrs.clear();

    for (auto& path_ptr : xml_file_path_ptrs) {
      try {
        ptree_ptr pt_ptr(new boost::property_tree::ptree());

        std::string path;
        switch (path_ptr->get_base_directory()) {
          case xml_file_path::base_directory::system_xml:
            path += system_xml_directory_;
            break;
          case xml_file_path::base_directory::private_xml:
            path += private_xml_directory_;
            break;
        }
        path += "/";
        path += path_ptr->get_relative_path();

        int flags = boost::property_tree::xml_parser::no_comments;

        std::string xml;
        pqrs::string::string_by_replacing_double_curly_braces_from_file(xml, path.c_str(), replacement_);
        std::stringstream istream(xml, std::stringstream::in);
        boost::property_tree::read_xml(istream, *pt_ptr, flags);

        pt_ptrs.push_back(pt_ptr);

      } catch (std::exception& e) {
        std::string what = e.what();

        // Hack:
        // boost::property_tree::read_xml throw exception with filename.
        // But, when we call read_xml with stream, the filename becomes "unspecified file" as follow.
        //
        // <unspecified file>(4): expected element name
        //
        // So, we change "unspecified file" to file name by ourself.
        boost::replace_first(what, "<unspecified file>", std::string("<") + path_ptr->get_relative_path() + ">");

        set_error_message_(what);
      }
    }
  }

  void
  xmlcompiler::set_error_message_(const std::string& message)
  {
    if (error_message_.empty()) {
      error_message_ = message;
    }
  }

  void
  xmlcompiler::normalize_identifier(std::string& identifier)
  {
    boost::replace_all(identifier, ".", "_");
  }
}
